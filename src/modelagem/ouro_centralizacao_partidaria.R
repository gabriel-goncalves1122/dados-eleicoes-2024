# ==============================================================================
# OURO 06: CENTRALIZAÇÃO PARTIDÁRIA E ORIGEM GEOGRÁFICA DE RECURSOS (16 COLUNAS)
# ==============================================================================
# Grão: partido x região x cargo. Mede dependência dos diretórios nacionais vs.
# estaduais/municipais, fluxo interestadual de doações e custo por eleito.

if (file.exists("src/modelagem/_helpers_ouro.R")) {
  source("src/modelagem/_helpers_ouro.R")
} else {
  source("_helpers_ouro.R")
}

message("=== [Ouro 06] Construindo ouro_centralizacao_partidaria.parquet ===")

com_conexao_duckdb(function(con) {
  sql <- sprintf("
    WITH rec_cand AS (
      SELECT
        r.sq_candidato,
        SUM(r.vr_receita) AS total_rec,
        SUM(CASE WHEN r.ds_esfera_partidaria_doador = 'NACIONAL' THEN r.vr_receita ELSE 0.0 END) AS vl_nacional,
        SUM(CASE WHEN CONTAINS(COALESCE(r.ds_esfera_partidaria_doador, ''), 'ESTADUAL') THEN r.vr_receita ELSE 0.0 END) AS vl_estadual,
        SUM(CASE WHEN r.ds_esfera_partidaria_doador = 'MUNICIPAL' THEN r.vr_receita ELSE 0.0 END) AS vl_municipal,
        SUM(CASE WHEN r.ds_esfera_partidaria_doador IS NULL THEN r.vr_receita ELSE 0.0 END) AS vl_outras,
        SUM(CASE WHEN r.sg_uf_doador IS NOT NULL AND r.sg_uf_doador != m.sg_uf THEN r.vr_receita ELSE 0.0 END) AS vl_fora_uf,
        SUM(CASE WHEN r.sg_uf_doador IS NOT NULL THEN r.vr_receita ELSE 0.0 END) AS vl_com_uf_info
      FROM read_parquet('%s') r
      JOIN read_parquet('%s') m ON r.cd_municipio_tse = m.cd_municipio_tse
      GROUP BY 1
    )
    SELECT
      p.nr_partido,
      p.sg_partido,
      p.sg_federacao,
      m.regiao,
      c.ds_cargo,
      CAST(COUNT(*) AS INTEGER) AS qtd_candidatos,
      CAST(SUM(CASE WHEN c.is_eleito THEN 1 ELSE 0 END) AS INTEGER) AS qtd_eleitos,
      AVG(CASE WHEN c.is_eleito THEN 100.0 ELSE 0.0 END) AS taxa_eleicao,
      SUM(COALESCE(r.total_rec, 0.0)) AS total_arrecadado,
      SUM(COALESCE(r.vl_nacional, 0.0)) AS vl_dir_nacional,
      SUM(COALESCE(r.vl_estadual, 0.0)) AS vl_dir_estadual,
      SUM(COALESCE(r.vl_municipal, 0.0)) AS vl_dir_municipal,
      SUM(COALESCE(r.vl_outras, 0.0)) AS vl_outras_fontes,
      CASE WHEN SUM(COALESCE(r.total_rec, 0.0)) > 0
           THEN SUM(COALESCE(r.vl_nacional, 0.0)) * 100.0 / SUM(COALESCE(r.total_rec, 0.0))
           ELSE NULL END AS pct_centralizacao_nacional,
      CASE WHEN SUM(COALESCE(r.vl_com_uf_info, 0.0)) > 0
           THEN SUM(COALESCE(r.vl_fora_uf, 0.0)) * 100.0 / SUM(COALESCE(r.vl_com_uf_info, 0.0))
           ELSE NULL END AS pct_dinheiro_fora_uf,
      CASE WHEN SUM(CASE WHEN c.is_eleito THEN 1 ELSE 0 END) > 0
           THEN SUM(COALESCE(r.total_rec, 0.0)) / SUM(CASE WHEN c.is_eleito THEN 1 ELSE 0 END)
           ELSE NULL END AS custo_por_eleito
    FROM read_parquet('%s') c
    JOIN read_parquet('%s') p ON c.nr_partido = p.nr_partido
    JOIN read_parquet('%s') m ON c.cd_municipio_tse = m.cd_municipio_tse
    LEFT JOIN rec_cand r ON c.sq_candidato = r.sq_candidato
    GROUP BY 1, 2, 3, 4, 5
  ",
    prata_sql("fato_receitas.parquet"),
    prata_sql("dim_municipio.parquet"),
    prata_sql("dim_candidato.parquet"),
    prata_sql("dim_partido.parquet"),
    prata_sql("dim_municipio.parquet")
  )
  n <- executar_copy_parquet(con, sql, ouro_dest("ouro_centralizacao_partidaria.parquet"))
  message("✔ dados/ouro/ouro_centralizacao_partidaria.parquet salvo (", n, " linhas, 16 colunas)")
})
