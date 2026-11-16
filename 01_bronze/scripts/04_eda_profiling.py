# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "polars>=1.0",
#     "duckdb>=1.0",
# ]
# ///
"""
EDA & Data Profiling da Camada Bronze (100% Parquet).

Gera perfis estatisticos completos de todos os datasets Parquet da camada
01_bronze/data/, exportando os resultados em HTML interativo, Markdown e JSON
dentro de 01_bronze/eda/.

Execucao:
    uv run 01_bronze/scripts/04_eda_profiling.py
"""

from __future__ import annotations

import html
import json
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

import duckdb
import polars as pl

SENTINEL_VALUES = ("#NULO#", "#NULO", "#NE#", "-1", "-3", "...", "-", "")


@dataclass(frozen=True)
class ColumnProfile:
    """Perfil estatistico imutavel de uma coluna."""

    name: str
    dtype: str
    total_rows: int
    null_count: int
    null_pct: float
    sentinel_count: int
    sentinel_pct: float
    distinct_count: int
    min_val: str
    max_val: str
    top_values: list[dict[str, Any]]


@dataclass(frozen=True)
class DatasetProfile:
    """Perfil estatistico imutavel de um arquivo Parquet."""

    domain: str
    name: str
    relative_path: str
    size_mb: float
    rows: int
    columns: int
    duplicate_rows: int
    column_profiles: list[ColumnProfile]


# ==============================================================================
# NUCLEO FUNCIONAL (Funcoes Puras / Vetorizadas)
# ==============================================================================


def _format_scalar(value: Any) -> str:
    """Formata valores escalares para exibicao compacta."""
    if value is None:
        return "—"
    text = str(value).strip()
    return text[:45] + "..." if len(text) > 48 else text


def profile_dataframe(
    df: pl.DataFrame,
    domain: str,
    name: str,
    relative_path: str,
    size_mb: float,
) -> DatasetProfile:
    """Computa o perfil completo de um DataFrame Polars de forma vetorizada."""
    total_rows = df.height
    col_names = df.columns

    # Contagem de nulos e cardinalidade em uma unica passada colunar
    null_counts = df.null_count().row(0, named=True)
    n_unique_row = df.select([pl.col(c).n_unique().alias(c) for c in col_names]).row(0, named=True)

    # Checa duplicatas exatas (em amostra se > 500k linhas para manter velocidade sub-segundo)
    dup_rows = (
        df.height - df.unique().height
        if total_rows <= 500_000
        else -1
    )

    col_profiles: list[ColumnProfile] = []
    for col in col_names:
        series = df.get_column(col)
        dtype_str = str(series.dtype)
        null_cnt = int(null_counts[col])
        null_pct = round((null_cnt / total_rows) * 100, 2) if total_rows > 0 else 0.0
        distinct_cnt = int(n_unique_row[col])

        # Contagem de sentinelas comuns do TSE / IBGE
        if series.dtype == pl.String:
            sentinel_cnt = int(
                series.str.strip_chars().is_in(SENTINEL_VALUES).fill_null(False).sum()
            )
            valid_series = series.filter(
                series.is_not_null() & ~series.str.strip_chars().is_in(SENTINEL_VALUES)
            )
        else:
            sentinel_cnt = 0
            valid_series = series.drop_nulls()

        sentinel_pct = round((sentinel_cnt / total_rows) * 100, 2) if total_rows > 0 else 0.0

        min_v = _format_scalar(valid_series.min()) if valid_series.len() > 0 else "—"
        max_v = _format_scalar(valid_series.max()) if valid_series.len() > 0 else "—"

        # Top 5 valores mais frequentes
        top_df = (
            df.select(pl.col(col).cast(pl.String).fill_null("<NULL>").alias("val"))
            .group_by("val")
            .len()
            .sort("len", descending=True)
            .head(5)
        )
        top_values = [
            {
                "value": _format_scalar(r["val"]),
                "count": int(r["len"]),
                "pct": round((int(r["len"]) / total_rows) * 100, 2) if total_rows > 0 else 0.0,
            }
            for r in top_df.iter_rows(named=True)
        ]

        col_profiles.append(
            ColumnProfile(
                name=col,
                dtype=dtype_str,
                total_rows=total_rows,
                null_count=null_cnt,
                null_pct=null_pct,
                sentinel_count=sentinel_cnt,
                sentinel_pct=sentinel_pct,
                distinct_count=distinct_cnt,
                min_val=min_v,
                max_val=max_v,
                top_values=top_values,
            )
        )

    return DatasetProfile(
        domain=domain,
        name=name,
        relative_path=relative_path,
        size_mb=round(size_mb, 2),
        rows=total_rows,
        columns=len(col_names),
        duplicate_rows=dup_rows,
        column_profiles=col_profiles,
    )


def render_markdown(profiles: list[DatasetProfile], generated_at: str) -> str:
    """Renderiza o relatorio completo em Markdown legivel para humanos e IAs."""
    total_rows = sum(p.rows for p in profiles)
    total_mb = round(sum(p.size_mb for p in profiles), 2)

    lines = [
        "# EDA & Data Profiling — Camada Bronze (100% Parquet)",
        f"> Gerado em: `{generated_at}` | Datasets: **{len(profiles)}** | Registros Totais: **{total_rows:,}** | Espaço em Disco: **{total_mb} MB**",
        "",
        "## 1. Visão Geral dos Datasets",
        "",
        "| Domínio | Dataset | Arquivo | Linhas | Colunas | Tamanho (MB) | Duplicatas |",
        "| :--- | :--- | :--- | ---: | ---: | ---: | ---: |",
    ]

    for p in profiles:
        dup_str = f"{p.duplicate_rows:,}" if p.duplicate_rows >= 0 else "N/A (>500k)"
        lines.append(
            f"| `{p.domain}` | **{p.name}** | `{p.relative_path}` | {p.rows:,} | {p.columns} | {p.size_mb:.2f} | {dup_str} |"
        )

    lines.extend(["", "---", "", "## 2. Alertas de Qualidade (Nulos e Sentinelas TSE/IBGE)", ""])
    alerts: list[str] = []
    for p in profiles:
        for c in p.column_profiles:
            if c.null_pct >= 20 or c.sentinel_pct >= 10:
                alerts.append(
                    f"- **`{p.domain}/{p.name}.{c.name}`**: Nulos = `{c.null_pct}%` ({c.null_count:,}) | "
                    f"Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `{c.sentinel_pct}%` ({c.sentinel_count:,})"
                )
    if alerts:
        lines.extend(alerts)
    else:
        lines.append("- Nenhum alerta crítico de nulos (>=20%) ou sentinelas (>=10%) detectado.")

    lines.extend(["", "---", "", "## 3. Perfil Detalhado por Dataset", ""])
    for p in profiles:
        lines.extend([
            f"### 📦 `{p.domain}/{p.name}` ({p.rows:,} linhas × {p.columns} colunas | {p.size_mb:.2f} MB)",
            "",
            "| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |",
            "| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |",
        ])
        for c in p.column_profiles:
            top3 = "; ".join(f"`{tv['value']}` ({tv['pct']}%)" for tv in c.top_values[:3])
            lines.append(
                f"| `{c.name}` | `{c.dtype}` | {c.null_pct}% | {c.sentinel_pct}% | {c.distinct_count:,} | "
                f"`{c.min_val}` | `{c.max_val}` | {top3} |"
            )
        lines.append("")

    return "\n".join(lines)


def render_html(profiles: list[DatasetProfile], generated_at: str) -> str:
    """Renderiza um relatório HTML moderno, autocontido e interativo."""
    total_rows = sum(p.rows for p in profiles)
    total_mb = round(sum(p.size_mb for p in profiles), 2)
    total_cols = sum(p.columns for p in profiles)

    cards_html = []
    for idx, p in enumerate(profiles):
        dup_str = f"{p.duplicate_rows:,}" if p.duplicate_rows >= 0 else "N/A (>500k)"
        rows_html = []
        for c in p.column_profiles:
            badge_cls = (
                "badge-warn" if (c.null_pct >= 20 or c.sentinel_pct >= 10) else "badge-ok"
            )
            top_list = "<br>".join(
                f"<code>{html.escape(tv['value'])}</code> <span class='muted'>({tv['pct']}%)</span>"
                for tv in c.top_values[:3]
            )
            rows_html.append(
                f"<tr>"
                f"<td><strong>{html.escape(c.name)}</strong></td>"
                f"<td><code>{html.escape(c.dtype)}</code></td>"
                f"<td><span class='{badge_cls}'>{c.null_pct}%</span></td>"
                f"<td><span class='{badge_cls}'>{c.sentinel_pct}%</span></td>"
                f"<td>{c.distinct_count:,}</td>"
                f"<td><code>{html.escape(c.min_val)}</code></td>"
                f"<td><code>{html.escape(c.max_val)}</code></td>"
                f"<td class='top-cell'>{top_list}</td>"
                f"</tr>"
            )

        open_attr = "open" if idx < 2 else ""
        cards_html.append(
            f"""
            <details class="dataset-card" {open_attr} data-search="{html.escape((p.domain + ' ' + p.name).lower())}">
                <summary>
                    <div class="ds-title">
                        <span class="domain-tag domain-{html.escape(p.domain)}">{html.escape(p.domain.upper())}</span>
                        <strong>{html.escape(p.name)}</strong>
                        <span class="muted">{html.escape(p.relative_path)}</span>
                    </div>
                    <div class="ds-meta">
                        <span>{p.rows:,} linhas</span>
                        <span>{p.columns} colunas</span>
                        <span>{p.size_mb:.2f} MB</span>
                        <span>Dup: {dup_str}</span>
                    </div>
                </summary>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Coluna</th><th>Tipo</th><th>Nulos</th><th>Sentinelas</th>
                                <th>Distintos</th><th>Mínimo</th><th>Máximo</th><th>Top 3 Valores</th>
                            </tr>
                        </thead>
                        <tbody>
                            {''.join(rows_html)}
                        </tbody>
                    </table>
                </div>
            </details>
            """
        )

    return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>EDA & Data Profiling — Camada Bronze</title>
<style>
  :root {{
    --bg: #0f172a; --card: #1e293b; --border: #334155;
    --text: #f1f5f9; --muted: #94a3b8; --accent: #38bdf8;
    --ok: #10b981; --warn: #f59e0b;
  }}
  * {{ box-sizing: border-box; }}
  body {{ font-family: system-ui, -apple-system, sans-serif; background: var(--bg); color: var(--text); margin: 0; padding: 24px; line-height: 1.5; }}
  .container {{ max-width: 1400px; margin: 0 auto; }}
  h1 {{ margin: 0 0 6px; font-size: 1.75rem; }}
  .subtitle {{ color: var(--muted); margin-bottom: 24px; font-size: 0.92rem; }}
  .kpi-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px; }}
  .kpi {{ background: var(--card); border: 1px solid var(--border); border-radius: 10px; padding: 16px; }}
  .kpi-label {{ color: var(--muted); font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.05em; }}
  .kpi-value {{ font-size: 1.6rem; font-weight: 700; color: var(--accent); margin-top: 4px; }}
  .search-box {{ width: 100%; padding: 12px 16px; border-radius: 8px; border: 1px solid var(--border); background: var(--card); color: var(--text); font-size: 0.95rem; margin-bottom: 18px; }}
  .dataset-card {{ background: var(--card); border: 1px solid var(--border); border-radius: 10px; margin-bottom: 14px; overflow: hidden; }}
  summary {{ padding: 14px 18px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; list-style: none; }}
  summary:hover {{ background: rgba(56, 189, 248, 0.06); }}
  .ds-title {{ display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }}
  .ds-meta {{ display: flex; gap: 14px; font-size: 0.85rem; color: var(--muted); }}
  .domain-tag {{ font-size: 0.72rem; font-weight: 700; padding: 2px 8px; border-radius: 999px; background: #334155; color: #e2e8f0; }}
  .domain-tse {{ background: #1d4ed8; }}
  .domain-ibge {{ background: #047857; }}
  .domain-integracao {{ background: #7c3aed; }}
  .table-wrap {{ overflow-x: auto; border-top: 1px solid var(--border); }}
  table {{ width: 100%; border-collapse: collapse; font-size: 0.84rem; }}
  th, td {{ padding: 9px 12px; text-align: left; border-bottom: 1px solid var(--border); vertical-align: top; }}
  th {{ background: #0f172a; color: var(--muted); font-weight: 600; position: sticky; top: 0; }}
  code {{ background: rgba(15, 23, 42, 0.7); padding: 2px 5px; border-radius: 4px; font-size: 0.8rem; color: #cbd5e1; }}
  .muted {{ color: var(--muted); font-size: 0.8rem; }}
  .badge-ok {{ color: var(--ok); font-weight: 600; }}
  .badge-warn {{ color: var(--warn); font-weight: 700; }}
  .top-cell {{ min-width: 220px; }}
</style>
</head>
<body>
<div class="container">
  <h1>📊 EDA &amp; Data Profiling — Camada Bronze (100% Parquet)</h1>
  <div class="subtitle">Gerado em {html.escape(generated_at)} &bull; Análise automatizada de qualidade, cardinalidade e distribuição</div>
  <div class="kpi-grid">
    <div class="kpi"><div class="kpi-label">Datasets Parquet</div><div class="kpi-value">{len(profiles)}</div></div>
    <div class="kpi"><div class="kpi-label">Total de Registros</div><div class="kpi-value">{total_rows:,}</div></div>
    <div class="kpi"><div class="kpi-label">Total de Colunas</div><div class="kpi-value">{total_cols}</div></div>
    <div class="kpi"><div class="kpi-label">Espaço em Disco</div><div class="kpi-value">{total_mb} MB</div></div>
  </div>
  <input id="filterInput" class="search-box" type="text" placeholder="Filtrar datasets por nome ou domínio (ex: tse, ibge, despesas, censo)...">
  {''.join(cards_html)}
</div>
<script>
  document.getElementById('filterInput').addEventListener('input', function(e) {{
    const q = e.target.value.toLowerCase().trim();
    document.querySelectorAll('.dataset-card').forEach(card => {{
      const txt = card.getAttribute('data-search') || '';
      card.style.display = txt.includes(q) ? '' : 'none';
    }});
  }});
</script>
</body>
</html>
"""


# ==============================================================================
# CASCA IMPERATIVA (I/O e Orquestracao)
# ==============================================================================


def discover_bronze_parquets(bronze_data_dir: Path) -> list[tuple[str, Path]]:
    """Descobre todos os arquivos .parquet na camada Bronze."""
    files = sorted(bronze_data_dir.rglob("*.parquet"))
    discovered: list[tuple[str, Path]] = []
    for f in files:
        rel = f.relative_to(bronze_data_dir)
        domain = rel.parts[0] if len(rel.parts) > 1 else "integracao"
        discovered.append((domain, f))
    return discovered


def main() -> None:
    root = Path.cwd()
    bronze_data = root / "01_bronze" / "data"
    eda_dir = root / "01_bronze" / "eda"
    eda_dir.mkdir(parents=True, exist_ok=True)

    parquet_files = discover_bronze_parquets(bronze_data)
    if not parquet_files:
        raise FileNotFoundError(f"Nenhum arquivo .parquet encontrado em {bronze_data}")

    print(f"=== Iniciando Data Profiling Bronze ({len(parquet_files)} datasets Parquet) ===")
    profiles: list[DatasetProfile] = []
    con = duckdb.connect()

    for domain, path in parquet_files:
        rel_path = str(path.relative_to(root)).replace("\\", "/")
        size_mb = path.stat().st_size / (1024 * 1024)
        print(f"  -> Analisando [{domain}] {path.name} ({size_mb:.2f} MB)...", flush=True)
        # Leitura colunar via Polars (com fallback DuckDB se necessario)
        df = pl.read_parquet(path)
        profiles.append(profile_dataframe(df, domain, path.stem, rel_path, size_mb))

    con.close()
    generated_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Exportar em HTML, Markdown e JSON
    html_path = eda_dir / "eda_bronze_profile.html"
    md_path = eda_dir / "eda_bronze_resumo.md"
    json_path = eda_dir / "eda_bronze_profile.json"

    html_path.write_text(render_html(profiles, generated_at), encoding="utf-8")
    md_path.write_text(render_markdown(profiles, generated_at), encoding="utf-8")
    json_path.write_text(
        json.dumps([asdict(p) for p in profiles], indent=2, ensure_ascii=False),
        encoding="utf-8",
    )

    print("\n=== EDA & Data Profiling Bronze Concluido ===")
    print(f"  HTML     : {html_path}")
    print(f"  Markdown : {md_path}")
    print(f"  JSON     : {json_path}")


if __name__ == "__main__":
    main()
