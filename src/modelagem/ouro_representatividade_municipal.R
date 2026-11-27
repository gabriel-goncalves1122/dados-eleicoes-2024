# ==============================================================================
# OURO 02: REPRESENTATIVIDADE E FINANCIAMENTO EFETIVO MUNICIPAL (18 COLUNAS)
# ==============================================================================
# Compara os 4 estágios (População Censo -> Candidaturas -> Fundo Público -> Eleitos)
# por gênero e raça em todos os municípios brasileiros com eleição.

if (file.exists("src/modelagem/_helpers_ouro.R")) {
  source("src/modelagem/_helpers_ouro.R")
} else {
  source("_helpers_ouro.R")
}

message("=== [Ouro 02] Construindo ouro_representatividade_municipal.parquet ===")

com_conexao_duckdb(function(con) {
  sql <- sprintf("
    WITH rec_cand AS (
      SELECT
        sq_candidato,
        SUM(CASE WHEN is_fundo_publico THEN vr_receita ELSE 0.0 END) AS vl_fp
      FROM read_parquet('%s')
      GROUP BY 1
    ),
    base_mun AS (
      SELECT
        c.cd_municipio_tse,
        AVG(CASE WHEN c.ds_genero = 'FEMININO' THEN 100.0 ELSE 0.0 END) AS pct_cand_mulheres,
        AVG(CASE WHEN c.is_eleito AND c.ds_genero = 'FEMININO' THEN 100.0
                 WHEN c.is_eleito THEN 0.0 END) AS pct_eleitos_mulheres,
        AVG(CASE WHEN c.ds_cor_raca IN ('PRETA', 'PARDA', 'INDÍGENA') THEN 100.0 ELSE 0.0 END) AS pct_cand_negros_indigenas,
        AVG(CASE WHEN c.is_eleito AND c.ds_cor_raca IN ('PRETA', 'PARDA', 'INDÍGENA') THEN 100.0
                 WHEN c.is_eleito THEN 0.0 END) AS pct_eleitos_negros_indigenas,
        CASE WHEN SUM(COALESCE(r.vl_fp, 0.0)) > 0
             THEN SUM(CASE WHEN c.ds_genero = 'FEMININO' THEN COALESCE(r.vl_fp, 0.0) ELSE 0.0 END) * 100.0 / SUM(COALESCE(r.vl_fp, 0.0))
             ELSE NULL END AS pct_fundo_publico_mulheres,
        CASE WHEN SUM(COALESCE(r.vl_fp, 0.0)) > 0
             THEN SUM(CASE WHEN c.ds_cor_raca IN ('PRETA', 'PARDA', 'INDÍGENA') THEN COALESCE(r.vl_fp, 0.0) ELSE 0.0 END) * 100.0 / SUM(COALESCE(r.vl_fp, 0.0))
             ELSE NULL END AS pct_fundo_publico_negros_indigenas
      FROM read_parquet('%s') c
      LEFT JOIN rec_cand r ON c.sq_candidato = r.sq_candidato
      GROUP BY 1
    )
    SELECT
      m.cd_municipio_tse,
      m.cd_municipio_ibge,
      m.sg_uf,
      m.regiao,
      m.nm_municipio,
      m.porte_municipio,
      m.is_capital,
      i.pct_mulheres_censo,
      i.pct_negros_indigenas_censo,
      b.pct_cand_mulheres,
      b.pct_fundo_publico_mulheres,
      b.pct_eleitos_mulheres,
      b.pct_cand_negros_indigenas,
      b.pct_fundo_publico_negros_indigenas,
      b.pct_eleitos_negros_indigenas,
      b.pct_eleitos_mulheres - i.pct_mulheres_censo AS gap_eleitos_mulheres,
      b.pct_eleitos_negros_indigenas - i.pct_negros_indigenas_censo AS gap_eleitos_negros_indigenas,
      b.pct_fundo_publico_mulheres - b.pct_cand_mulheres AS gap_financiamento_mulheres
    FROM base_mun b
    JOIN read_parquet('%s') m ON b.cd_municipio_tse = m.cd_municipio_tse
    LEFT JOIN read_parquet('%s') i ON m.cd_municipio_ibge = i.cd_municipio_ibge
  ",
    prata_sql("fato_receitas.parquet"),
    prata_sql("dim_candidato.parquet"),
    prata_sql("dim_municipio.parquet"),
    prata_sql("fato_indicadores_municipio.parquet")
  )
  n <- executar_copy_parquet(con, sql, ouro_dest("ouro_representatividade_municipal.parquet"))
  message("✔ dados/ouro/ouro_representatividade_municipal.parquet salvo (", n, " municípios, 18 colunas)")
})
