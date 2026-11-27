# ==============================================================================
# OURO 01: BASE ENXUTA PARA PCA E TIPOLOGIA MUNICIPAL (20 COLUNAS)
# ==============================================================================
# Substitui o antigo datamart de 61 colunas mantendo apenas identificadores
# territoriais, perfil do prefeito eleito, indicadores IBGE e métricas eleitorais.

if (file.exists("src/modelagem/_helpers_ouro.R")) {
  source("src/modelagem/_helpers_ouro.R")
} else {
  source("_helpers_ouro.R")
}

message("=== [Ouro 01] Construindo ouro_pca_municipios.parquet ===")

com_conexao_duckdb(function(con) {
  sql <- sprintf("
    WITH cand_mun AS (
      SELECT
        cd_municipio_tse,
        AVG(CASE WHEN ds_genero = 'FEMININO' THEN 100.0 ELSE 0.0 END) AS pct_cand_mulheres,
        AVG(CASE WHEN is_eleito AND ds_genero = 'FEMININO' THEN 100.0
                 WHEN is_eleito THEN 0.0 END) AS pct_eleitos_mulheres
      FROM read_parquet('%s')
      GROUP BY 1
    ),
    vot_mun AS (
      SELECT cd_municipio_tse, SUM(qt_votos_nominais) AS total_votos_nominais
      FROM read_parquet('%s')
      GROUP BY 1
    ),
    rec_mun AS (
      SELECT
        cd_municipio_tse,
        SUM(vr_receita) AS total_arrecadado,
        SUM(CASE WHEN is_fundo_publico THEN vr_receita ELSE 0.0 END) AS total_fundo_publico
      FROM read_parquet('%s')
      GROUP BY 1
    ),
    desp_mun AS (
      SELECT cd_municipio_tse, SUM(vr_despesa_contratada) AS total_gasto
      FROM read_parquet('%s')
      GROUP BY 1
    ),
    pref_eleito AS (
      SELECT
        cd_municipio_tse,
        ds_genero AS prefeito_eleito_genero,
        ds_grau_instrucao AS prefeito_eleito_instrucao
      FROM read_parquet('%s')
      WHERE cd_cargo = 11 AND is_eleito
      QUALIFY ROW_NUMBER() OVER (PARTITION BY cd_municipio_tse ORDER BY nr_turno_final DESC, sq_candidato) = 1
    )
    SELECT
      m.cd_municipio_tse,
      m.cd_municipio_ibge,
      m.sg_uf,
      m.regiao,
      m.nm_municipio,
      m.porte_municipio,
      m.is_capital,
      p.prefeito_eleito_genero,
      p.prefeito_eleito_instrucao,
      i.pib_per_capita_reais,
      i.taxa_alfabetizacao_15mais,
      i.pct_populacao_urbana,
      i.pct_esgoto_adequado,
      i.pct_adm_publica_vab_2021,
      CASE WHEN i.populacao_2022 > 0
           THEN (COALESCE(v.total_votos_nominais, 0) * 100.0) / i.populacao_2022
           ELSE NULL END AS taxa_comparecimento_estimada,
      CASE WHEN i.populacao_2022 > 0
           THEN COALESCE(d.total_gasto, 0.0) / i.populacao_2022
           ELSE NULL END AS gasto_campanha_per_capita,
      CASE WHEN COALESCE(v.total_votos_nominais, 0) > 0
           THEN COALESCE(d.total_gasto, 0.0) / v.total_votos_nominais
           ELSE NULL END AS custo_medio_voto_municipio,
      CASE WHEN COALESCE(r.total_arrecadado, 0.0) > 0
           THEN (COALESCE(r.total_fundo_publico, 0.0) * 100.0) / r.total_arrecadado
           ELSE 0.0 END AS pct_fundo_publico_municipio,
      cm.pct_cand_mulheres,
      cm.pct_eleitos_mulheres
    FROM cand_mun cm
    JOIN read_parquet('%s') m ON cm.cd_municipio_tse = m.cd_municipio_tse
    LEFT JOIN read_parquet('%s') i ON m.cd_municipio_ibge = i.cd_municipio_ibge
    LEFT JOIN vot_mun v ON cm.cd_municipio_tse = v.cd_municipio_tse
    LEFT JOIN rec_mun r ON cm.cd_municipio_tse = r.cd_municipio_tse
    LEFT JOIN desp_mun d ON cm.cd_municipio_tse = d.cd_municipio_tse
    LEFT JOIN pref_eleito p ON cm.cd_municipio_tse = p.cd_municipio_tse
  ",
    prata_sql("dim_candidato.parquet"),
    prata_sql("fato_votacao.parquet"),
    prata_sql("fato_receitas.parquet"),
    prata_sql("fato_despesas.parquet"),
    prata_sql("dim_candidato.parquet"),
    prata_sql("dim_municipio.parquet"),
    prata_sql("fato_indicadores_municipio.parquet")
  )
  n <- executar_copy_parquet(con, sql, ouro_dest("ouro_pca_municipios.parquet"))
  message("✔ dados/ouro/ouro_pca_municipios.parquet salvo (", n, " municípios, 20 colunas)")
})
