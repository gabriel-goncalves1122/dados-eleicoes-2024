# ==============================================================================
# ANALYTICS 15: GERADOR DE APRESENTAÇÃO INTERATIVA (NAVEGAÇÃO TECLADO + MOUSE)
# ==============================================================================
# Gera 03_gold/analytics/output/index.html reunindo todos os 15 gráficos Plotly
# com navegação por setas do teclado (← / →) e mouse, com ajuste automático de
# bordas (resize) para nunca cortar títulos, eixos ou legendas.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

slides <- list(
  list(file = "00_exploracao_raca_candidatos.html", cat = "Exploração", title = "00. Distribuição de Cor/Raça dos Candidatos (2024)", q = "Qual a composição racial das 151.868 candidaturas em MG e SP?"),
  list(file = "01_roi_partidario.html", cat = "Finanças & ROI", title = "01. ROI Partidário — Top 10 Partidos (Prefeitos)", q = "Entre os 10 maiores partidos, quem tem menor custo por voto e maior taxa de vitória?"),
  list(file = "02_desigualdade_fundo.html", cat = "Finanças & ROI", title = "02. Desigualdade no Fundo Público (Violin Plot)", q = "Como o Fundo Eleitoral se distribui entre homens/mulheres e raças?"),
  list(file = "03_patrimonio_vs_votos.html", cat = "Finanças & ROI", title = "03. Top 50 Maiores Patrimônios vs. Votos", q = "Entre os 50 candidatos a prefeito mais ricos, quem venceu e quem perdeu?"),
  list(file = "04_top20_partidos.html", cat = "Finanças & ROI", title = "04. Top 20 Partidos (Público vs. Privado)", q = "Quais partidos arrecadaram mais e qual a origem dos recursos?"),
  list(file = "05_top_campanhas_milionarias.html", cat = "Finanças & ROI", title = "05. Top 25 Campanhas Milionárias (Eleitos vs. Não Eleitos)", q = "Os maiores orçamentos para prefeito venceram nas urnas?"),
  list(file = "06_extremos_custo_voto.html", cat = "Finanças & ROI", title = "06. Extremos de Custo por Voto (Eleitos)", q = "Quais prefeitos eleitos tiveram o voto mais caro e o mais barato?"),
  list(file = "07_representatividade_genero_censo_urnas.html", cat = "Representatividade", title = "07. Funil da Representatividade Feminina (Censo ➔ Urnas)", q = "Como cai a presença feminina da população (50%) até as prefeitas eleitas?"),
  list(file = "08_representatividade_raca_censo_urnas.html", cat = "Representatividade", title = "08. Representatividade Racial: Censo 2022 vs. Eleitos 2024", q = "Brancos estão sobre-representados e pardos/pretos sub-representados entre os eleitos?"),
  list(file = "09_gap_representatividade_porte_uf.html", cat = "Representatividade", title = "09. Evolução da Representatividade por Porte do Município", q = "Cidades maiores elegem mais mulheres e pessoas negras do que cidades pequenas?"),
  list(file = "10_economia_publica_vs_campanhas.html", cat = "Economia & Desenvolvimento", title = "10. Faixas de Dependência da Prefeitura vs. Gasto por Habitante", q = "Quanto mais o município depende da prefeitura (% VAB), mais cara é a campanha?"),
  list(file = "11_desenvolvimento_vs_escolaridade_prefeito.html", cat = "Economia & Desenvolvimento", title = "11. Taxa de Sucesso Eleitoral por Grau de Instrução", q = "Candidatos com Ensino Superior Completo têm maior chance de vitória?"),
  list(file = "12_destino_gastos_eleitos_vs_naoeleitos.html", cat = "Gastos & Hegemonia", title = "12. Destino dos Gastos: Eleitos vs. Não Eleitos", q = "Em que categorias se gasta o orçamento e o que difere nos eleitos?"),
  list(file = "13_curva_temporal_gastos_campanha.html", cat = "Gastos & Hegemonia", title = "13. Curva Temporal dos Gastos (Ago–Out 2024)", q = "Qual o ritmo diário de gastos até o 1º e 2º turnos?"),
  list(file = "14_hegemonia_partidaria_porte_pib.html", cat = "Gastos & Hegemonia", title = "14. Hegemonia Partidária: Riqueza vs. Setor Público", q = "Quais partidos governam cidades ricas vs. dependentes do setor público?")
)

json_slides <- jsonlite::toJSON(slides, auto_unbox = TRUE)

html_doc <- sprintf('<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Apresentação Analítica — Eleições 2024 (TSE + IBGE)</title>
<style>
  :root {
    --bg: #0f172a; --panel: #1e293b; --border: #334155;
    --text: #f8fafc; --muted: #94a3b8; --accent: #38bdf8;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body { height: 100%%; width: 100%%; overflow: hidden; font-family: system-ui, -apple-system, sans-serif; background: var(--bg); color: var(--text); }
  .app { display: flex; flex-direction: column; height: 100vh; width: 100vw; }
  header {
    display: flex; align-items: center; justify-content: space-between; gap: 16px;
    padding: 10px 20px; background: var(--panel); border-bottom: 1px solid var(--border);
    flex-shrink: 0; min-height: 62px;
  }
  .title-block { display: flex; flex-direction: column; min-width: 0; }
  .cat-badge {
    display: inline-block; font-size: 0.7rem; font-weight: 700; text-transform: uppercase;
    letter-spacing: 0.06em; color: var(--accent); margin-bottom: 2px;
  }
  h1 { font-size: 1.05rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .question { font-size: 0.82rem; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .controls { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
  button, select {
    background: #0f172a; color: var(--text); border: 1px solid var(--border);
    border-radius: 8px; padding: 7px 12px; font-size: 0.85rem; cursor: pointer;
  }
  button:hover:not(:disabled) { border-color: var(--accent); color: var(--accent); }
  button:disabled { opacity: 0.4; cursor: not-allowed; }
  select { max-width: 260px; }
  .counter { font-size: 0.85rem; color: var(--muted); min-width: 56px; text-align: center; font-variant-numeric: tabular-nums; }
  .stage {
    flex: 1 1 auto; padding: 14px 18px; display: flex; min-height: 0; width: 100%%;
  }
  .frame-box {
    flex: 1 1 auto; background: #ffffff; border-radius: 12px; border: 1px solid var(--border);
    padding: 10px 14px; overflow: hidden; display: flex; min-height: 0; box-shadow: 0 10px 30px rgba(0,0,0,0.35);
  }
  iframe { width: 100%%; height: 100%%; border: none; display: block; }
  footer {
    padding: 6px 20px; background: var(--panel); border-top: 1px solid var(--border);
    font-size: 0.76rem; color: var(--muted); display: flex; justify-content: space-between; flex-shrink: 0;
  }
  kbd { background: #0f172a; border: 1px solid var(--border); border-radius: 4px; padding: 1px 5px; font-size: 0.72rem; color: var(--text); }
</style>
</head>
<body>
<div class="app">
  <header>
    <div class="title-block">
      <span id="catBadge" class="cat-badge"></span>
      <h1 id="slideTitle"></h1>
      <span id="slideQuestion" class="question"></span>
    </div>
    <div class="controls">
      <button id="btnPrev" title="Anterior (Seta Esquerda)">◀ Anterior</button>
      <span id="counter" class="counter"></span>
      <button id="btnNext" title="Próximo (Seta Direita)">Próximo ▶</button>
      <select id="slideSelect" aria-label="Selecionar gráfico"></select>
    </div>
  </header>

  <main class="stage">
    <div class="frame-box">
      <iframe id="chartFrame" title="Gráfico Interativo"></iframe>
    </div>
  </main>

  <footer>
    <span>Navegação: <kbd>←</kbd> <kbd>→</kbd> ou <kbd>PageUp</kbd> / <kbd>PageDown</kbd> | <kbd>Home</kbd> / <kbd>End</kbd> ou clique nos botões</span>
    <span>Eleições Municipais 2024 (MG &amp; SP) — Camada Gold (TSE + IBGE Censo 2022/PIB)</span>
  </footer>
</div>

<script>
  const slides = %s;
  let current = 0;

  const catBadge = document.getElementById("catBadge");
  const slideTitle = document.getElementById("slideTitle");
  const slideQuestion = document.getElementById("slideQuestion");
  const counter = document.getElementById("counter");
  const btnPrev = document.getElementById("btnPrev");
  const btnNext = document.getElementById("btnNext");
  const slideSelect = document.getElementById("slideSelect");
  const chartFrame = document.getElementById("chartFrame");

  slides.forEach((s, i) => {
    const opt = document.createElement("option");
    opt.value = i;
    opt.textContent = s.title;
    slideSelect.appendChild(opt);
  });

  function ajustarPlotlyNoIframe() {
    try {
      const win = chartFrame.contentWindow;
      const doc = chartFrame.contentDocument;
      if (!win || !doc) return;
      doc.documentElement.style.height = "100%%";
      doc.body.style.height = "100%%";
      doc.body.style.margin = "0";
      doc.body.style.padding = "6px 10px";
      doc.body.style.boxSizing = "border-box";
      doc.body.style.overflow = "hidden";
      const plots = doc.querySelectorAll(".js-plotly-plot");
      plots.forEach(p => {
        p.style.width = "100%%";
        p.style.height = "calc(100vh - 16px)";
        if (win.Plotly && win.Plotly.Plots) {
          win.Plotly.relayout(p, {
            autosize: true,
            "margin.t": 75,
            "margin.b": 70,
            "margin.l": 75,
            "margin.r": 40
          });
          win.Plotly.Plots.resize(p);
        }
      });
    } catch (e) {}
  }

  chartFrame.addEventListener("load", () => {
    setTimeout(ajustarPlotlyNoIframe, 120);
    setTimeout(ajustarPlotlyNoIframe, 450);
  });
  window.addEventListener("resize", ajustarPlotlyNoIframe);

  function goTo(idx) {
    if (idx < 0 || idx >= slides.length) return;
    current = idx;
    const s = slides[current];
    catBadge.textContent = s.cat;
    slideTitle.textContent = s.title;
    slideQuestion.textContent = s.q;
    counter.textContent = `${current + 1} / ${slides.length}`;
    slideSelect.value = current;
    btnPrev.disabled = current === 0;
    btnNext.disabled = current === slides.length - 1;
    chartFrame.src = s.file;
  }

  btnPrev.addEventListener("click", () => goTo(current - 1));
  btnNext.addEventListener("click", () => goTo(current + 1));
  slideSelect.addEventListener("change", (e) => goTo(Number(e.target.value)));

  document.addEventListener("keydown", (e) => {
    if (e.key === "ArrowRight" || e.key === "PageDown") { e.preventDefault(); goTo(current + 1); }
    else if (e.key === "ArrowLeft" || e.key === "PageUp") { e.preventDefault(); goTo(current - 1); }
    else if (e.key === "Home") { e.preventDefault(); goTo(0); }
    else if (e.key === "End") { e.preventDefault(); goTo(slides.length - 1); }
  });

  goTo(0);
</script>
</body>
</html>
', json_slides)

out_path <- "03_gold/analytics/output/index.html"
writeLines(html_doc, out_path, useBytes = FALSE)
message("🎬 Apresentação interativa gerada em: ", out_path)
