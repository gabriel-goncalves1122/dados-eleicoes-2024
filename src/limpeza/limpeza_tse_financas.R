# ==============================================================================
# LIMPEZA PRATA 03: FATOS FINANCEIROS E BENS ATÔMICOS TSE 2024 (CONSTELAÇÃO)
# ==============================================================================
# Processa colunarmente via DuckDB direto de dados/bronze/tse/ para dados/prata/:
#   - fato_receitas.parquet (grão: lançamento de receita + origem doador/partido)
#   - fato_despesas.parquet (grão: lançamento de despesa + UF/município/CNAE forn.)
#   - fato_bens.parquet     (grão atômico: 1 linha por bem declarado)

if (file.exists("src/config.R")) {
  source("src/config.R")
  source("src/limpeza/_helpers_duckdb.R")
} else {
  source("../../src/config.R")
  source("_helpers_duckdb.R")
}

dir_create(DADOS_PRATA)
message("=== [Prata] Construindo fato_receitas, fato_despesas e fato_bens (DuckDB) ===")

arq_rec_in  <- normalizePath(path(DADOS_BRONZE, "tse", "receitas.parquet"), winslash = "/")
arq_desp_in <- normalizePath(path(DADOS_BRONZE, "tse", "despesas.parquet"), winslash = "/")
arq_bens_in <- normalizePath(path(DADOS_BRONZE, "tse", "bens.parquet"), winslash = "/")

com_conexao_duckdb(function(con) {
  # 1. fato_receitas.parquet
  sql_receitas <- sprintf("
    SELECT
      CAST(SQ_CANDIDATO AS VARCHAR) AS sq_candidato,
      LPAD(CAST(SG_UE AS VARCHAR), 5, '0') AS cd_municipio_tse,
      TRY_STRPTIME(CAST(DT_RECEITA AS VARCHAR), '%%d/%%m/%%Y')::DATE AS dt_receita,
      TRY_CAST(ST_TURNO AS INTEGER) AS st_turno,
      TRY_CAST(REPLACE(CAST(VR_RECEITA AS VARCHAR), ',', '.') AS DOUBLE) AS vr_receita,
      %s AS ds_fonte_receita,
      %s AS ds_origem_receita,
      %s AS ds_natureza_receita,
      %s AS ds_especie_receita,
      %s AS nr_cpf_cnpj_doador,
      %s AS nm_doador,
      %s AS cd_cnae_doador,
      %s AS ds_cnae_doador,
      %s AS sg_uf_doador,
      LPAD(%s, 5, '0') AS cd_municipio_doador,
      %s AS ds_esfera_partidaria_doador,
      %s AS sq_candidato_doador,
      REGEXP_MATCHES(COALESCE(%s, ''), '(?i)FUNDO ESPECIAL|FUNDO PARTID') AS is_fundo_publico
    FROM read_parquet('%s')
    WHERE SQ_CANDIDATO IS NOT NULL
      AND TRY_CAST(REPLACE(CAST(VR_RECEITA AS VARCHAR), ',', '.') AS DOUBLE) >= 0
  ",
    sql_limpar("DS_FONTE_RECEITA"),
    sql_limpar("DS_ORIGEM_RECEITA"),
    sql_limpar("DS_NATUREZA_RECEITA"),
    sql_limpar("DS_ESPECIE_RECEITA"),
    sql_limpar("NR_CPF_CNPJ_DOADOR"),
    sql_limpar("NM_DOADOR", upper = TRUE),
    sql_limpar("CD_CNAE_DOADOR"),
    sql_limpar("DS_CNAE_DOADOR", upper = TRUE),
    sql_limpar("SG_UF_DOADOR", upper = TRUE),
    sql_limpar("CD_MUNICIPIO_DOADOR"),
    sql_limpar("DS_ESFERA_PARTIDARIA_DOADOR", upper = TRUE),
    sql_limpar("SQ_CANDIDATO_DOADOR"),
    sql_limpar("DS_FONTE_RECEITA"),
    arq_rec_in
  )
  n_rec <- executar_copy_parquet(con, sql_receitas, path(DADOS_PRATA, "fato_receitas.parquet"))
  message("✔ dados/prata/fato_receitas.parquet salvo (", n_rec, " registros)")

  # 2. fato_despesas.parquet
  sql_despesas <- sprintf("
    SELECT
      CAST(SQ_CANDIDATO AS VARCHAR) AS sq_candidato,
      LPAD(CAST(SG_UE AS VARCHAR), 5, '0') AS cd_municipio_tse,
      TRY_STRPTIME(CAST(DT_DESPESA AS VARCHAR), '%%d/%%m/%%Y')::DATE AS dt_despesa,
      TRY_CAST(ST_TURNO AS INTEGER) AS st_turno,
      TRY_CAST(REPLACE(CAST(VR_DESPESA_CONTRATADA AS VARCHAR), ',', '.') AS DOUBLE) AS vr_despesa_contratada,
      %s AS ds_origem_despesa,
      %s AS ds_despesa,
      %s AS ds_tipo_documento,
      %s AS nr_cpf_cnpj_fornecedor,
      %s AS nm_fornecedor,
      %s AS cd_cnae_fornecedor,
      %s AS ds_cnae_fornecedor,
      %s AS sg_uf_fornecedor,
      LPAD(%s, 5, '0') AS cd_municipio_fornecedor,
      %s AS ds_esfera_part_fornecedor
    FROM read_parquet('%s')
    WHERE SQ_CANDIDATO IS NOT NULL
      AND TRY_CAST(REPLACE(CAST(VR_DESPESA_CONTRATADA AS VARCHAR), ',', '.') AS DOUBLE) >= 0
  ",
    sql_limpar("DS_ORIGEM_DESPESA"),
    sql_limpar("DS_DESPESA"),
    sql_limpar("DS_TIPO_DOCUMENTO"),
    sql_limpar("NR_CPF_CNPJ_FORNECEDOR"),
    sql_limpar("NM_FORNECEDOR", upper = TRUE),
    sql_limpar("CD_CNAE_FORNECEDOR"),
    sql_limpar("DS_CNAE_FORNECEDOR", upper = TRUE),
    sql_limpar("SG_UF_FORNECEDOR", upper = TRUE),
    sql_limpar("CD_MUNICIPIO_FORNECEDOR"),
    sql_limpar("DS_ESFERA_PART_FORNECEDOR", upper = TRUE),
    arq_desp_in
  )
  n_desp <- executar_copy_parquet(con, sql_despesas, path(DADOS_PRATA, "fato_despesas.parquet"))
  message("✔ dados/prata/fato_despesas.parquet salvo (", n_desp, " registros)")

  # 3. fato_bens.parquet (grão atômico: 1 linha por bem declarado)
  sql_bens <- sprintf("
    SELECT
      CAST(SQ_CANDIDATO AS VARCHAR) AS sq_candidato,
      TRY_CAST(NR_ORDEM_BEM_CANDIDATO AS INTEGER) AS nr_ordem_bem,
      %s AS ds_tipo_bem,
      %s AS ds_bem_candidato,
      TRY_CAST(REPLACE(CAST(VR_BEM_CANDIDATO AS VARCHAR), ',', '.') AS DOUBLE) AS vr_bem
    FROM read_parquet('%s')
    WHERE SQ_CANDIDATO IS NOT NULL
      AND TRY_CAST(REPLACE(CAST(VR_BEM_CANDIDATO AS VARCHAR), ',', '.') AS DOUBLE) >= 0
  ",
    sql_limpar("DS_TIPO_BEM_CANDIDATO", upper = TRUE),
    sql_limpar("DS_BEM_CANDIDATO", upper = TRUE),
    arq_bens_in
  )
  n_bens <- executar_copy_parquet(con, sql_bens, path(DADOS_PRATA, "fato_bens.parquet"))
  message("✔ dados/prata/fato_bens.parquet salvo (", n_bens, " bens atômicos)")
})
