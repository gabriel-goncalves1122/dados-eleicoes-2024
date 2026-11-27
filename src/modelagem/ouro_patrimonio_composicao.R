# ==============================================================================
# OURO 04: COMPOSIÇÃO PATRIMONIAL DOS CANDIDATOS (18 COLUNAS)
# ==============================================================================
# Classifica os 911k bens atômicos de fato_bens em 6 macro-classes econômicas
# (imóveis urbanos, terra rural, empresas/ações, veículos, espécie, outros).

if (file.exists("src/modelagem/_helpers_ouro.R")) {
  source("src/modelagem/_helpers_ouro.R")
} else {
  source("_helpers_ouro.R")
}

message("=== [Ouro 04] Construindo ouro_patrimonio_composicao.parquet ===")

com_conexao_duckdb(function(con) {
  sql <- sprintf("
    WITH bens_cls AS (
      SELECT
        sq_candidato,
        COUNT(*) AS qtd_bens,
        SUM(vr_bem) AS patrimonio_total,
        SUM(CASE WHEN ds_tipo_bem IN ('CASA', 'APARTAMENTO', 'TERRENO', 'SALA OU CONJUNTO', 'LOJA', 'GALPÃO', 'PRÉDIO COMERCIAL', 'PRÉDIO RESIDENCIAL', 'OUTROS BENS IMÓVEIS')
                 THEN vr_bem ELSE 0.0 END) AS vl_imoveis_urbanos,
        SUM(CASE WHEN ds_tipo_bem = 'TERRA NUA' OR CONTAINS(COALESCE(ds_tipo_bem, ''), 'RURAL')
                 THEN vr_bem ELSE 0.0 END) AS vl_terra_rural,
        SUM(CASE WHEN CONTAINS(COALESCE(ds_tipo_bem, ''), 'QUOTAS')
                   OR CONTAINS(COALESCE(ds_tipo_bem, ''), 'AÇÕES')
                   OR CONTAINS(COALESCE(ds_tipo_bem, ''), 'SOCIETÁRIAS')
                 THEN vr_bem ELSE 0.0 END) AS vl_empresas_acoes,
        SUM(CASE WHEN CONTAINS(COALESCE(ds_tipo_bem, ''), 'VEÍCULO')
                   OR CONTAINS(COALESCE(ds_tipo_bem, ''), 'AERONAVE')
                   OR CONTAINS(COALESCE(ds_tipo_bem, ''), 'EMBARCAÇÃO')
                 THEN vr_bem ELSE 0.0 END) AS vl_veiculos,
        SUM(CASE WHEN CONTAINS(COALESCE(ds_tipo_bem, ''), 'ESPÉCIE')
                 THEN vr_bem ELSE 0.0 END) AS vl_dinheiro_especie
      FROM read_parquet('%s')
      GROUP BY 1
    )
    SELECT
      c.sq_candidato,
      m.sg_uf,
      m.regiao,
      m.porte_municipio,
      p.sg_partido,
      c.ds_cargo,
      c.ds_genero,
      c.is_eleito,
      CAST(COALESCE(b.qtd_bens, 0) AS INTEGER) AS qtd_bens,
      COALESCE(b.patrimonio_total, 0.0) AS patrimonio_total,
      COALESCE(b.vl_imoveis_urbanos, 0.0) AS vl_imoveis_urbanos,
      COALESCE(b.vl_terra_rural, 0.0) AS vl_terra_rural,
      COALESCE(b.vl_empresas_acoes, 0.0) AS vl_empresas_acoes,
      COALESCE(b.vl_veiculos, 0.0) AS vl_veiculos,
      COALESCE(b.vl_dinheiro_especie, 0.0) AS vl_dinheiro_especie,
      GREATEST(
        COALESCE(b.patrimonio_total, 0.0)
        - COALESCE(b.vl_imoveis_urbanos, 0.0)
        - COALESCE(b.vl_terra_rural, 0.0)
        - COALESCE(b.vl_empresas_acoes, 0.0)
        - COALESCE(b.vl_veiculos, 0.0)
        - COALESCE(b.vl_dinheiro_especie, 0.0),
        0.0
      ) AS vl_outros_aplicacoes,
      CASE WHEN COALESCE(b.patrimonio_total, 0.0) > 0
           THEN (COALESCE(b.vl_dinheiro_especie, 0.0) * 100.0) / b.patrimonio_total
           ELSE 0.0 END AS pct_dinheiro_especie,
      CASE WHEN COALESCE(b.patrimonio_total, 0.0) > 0
           THEN (COALESCE(b.vl_terra_rural, 0.0) * 100.0) / b.patrimonio_total
           ELSE 0.0 END AS pct_terra_rural
    FROM read_parquet('%s') c
    JOIN read_parquet('%s') m ON c.cd_municipio_tse = m.cd_municipio_tse
    JOIN read_parquet('%s') p ON c.nr_partido = p.nr_partido
    LEFT JOIN bens_cls b ON c.sq_candidato = b.sq_candidato
  ",
    prata_sql("fato_bens.parquet"),
    prata_sql("dim_candidato.parquet"),
    prata_sql("dim_municipio.parquet"),
    prata_sql("dim_partido.parquet")
  )
  n <- executar_copy_parquet(con, sql, ouro_dest("ouro_patrimonio_composicao.parquet"))
  message("✔ dados/ouro/ouro_patrimonio_composicao.parquet salvo (", n, " candidatos, 18 colunas)")
})
