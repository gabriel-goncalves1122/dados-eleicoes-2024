# ==============================================================================
# LIMPEZA PRATA 02: PARTIDOS, CANDIDATOS E VOTAÇÃO TSE 2024 (CONSTELAÇÃO)
# ==============================================================================
# Processa colunarmente via DuckDB direto de dados/bronze/tse/ para dados/prata/:
#   - dim_partido.parquet   (partidos e federações únicos)
#   - dim_candidato.parquet (perfil biográfico + flags 2º turno e naturalidade)
#   - fato_votacao.parquet  (votos nominais e válidos por zona/turno)

if (file.exists("src/config.R")) {
  source("src/config.R")
  source("src/limpeza/_helpers_duckdb.R")
} else {
  source("../../src/config.R")
  source("_helpers_duckdb.R")
}

dir_create(DADOS_PRATA)
message("=== [Prata] Construindo dim_partido, dim_candidato e fato_votacao (DuckDB) ===")

arq_cand_in <- normalizePath(path(DADOS_BRONZE, "tse", "candidatos.parquet"), winslash = "/")
arq_vot_in  <- normalizePath(path(DADOS_BRONZE, "tse", "votacao.parquet"), winslash = "/")

com_conexao_duckdb(function(con) {
  # 1. dim_partido.parquet
  sql_partido <- sprintf("
    SELECT
      TRY_CAST(NR_PARTIDO AS INTEGER) AS nr_partido,
      %s AS sg_partido,
      %s AS nm_partido,
      %s AS sg_federacao,
      %s AS nm_federacao
    FROM read_parquet('%s')
    WHERE TRY_CAST(NR_PARTIDO AS INTEGER) IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (
      PARTITION BY TRY_CAST(NR_PARTIDO AS INTEGER)
      ORDER BY TRY_CAST(%s AS INTEGER) NULLS LAST, SG_PARTIDO
    ) = 1
  ",
    sql_limpar("SG_PARTIDO", upper = TRUE),
    sql_limpar("NM_PARTIDO", upper = TRUE),
    sql_limpar("SG_FEDERACAO", upper = TRUE),
    sql_limpar("NM_FEDERACAO", upper = TRUE),
    arq_cand_in,
    sql_limpar("NR_FEDERACAO")
  )
  n_part <- executar_copy_parquet(con, sql_partido, path(DADOS_PRATA, "dim_partido.parquet"))
  message("✔ dados/prata/dim_partido.parquet salvo (", n_part, " partidos)")

  # 2. dim_candidato.parquet
  sql_candidato <- sprintf("
    WITH base AS (
      SELECT
        CAST(SQ_CANDIDATO AS VARCHAR) AS sq_candidato,
        LPAD(CAST(SG_UE AS VARCHAR), 5, '0') AS cd_municipio_tse,
        TRY_CAST(NR_PARTIDO AS INTEGER) AS nr_partido,
        TRY_CAST(CD_CARGO AS INTEGER) AS cd_cargo,
        %s AS ds_cargo,
        CAST(NR_CANDIDATO AS VARCHAR) AS nr_candidato,
        %s AS nm_candidato,
        %s AS nm_urna_candidato,
        %s AS sg_uf_nascimento,
        UPPER(TRIM(CAST(SG_UF AS VARCHAR))) AS sg_uf_cand,
        TRY_STRPTIME(CAST(DT_NASCIMENTO AS VARCHAR), '%%d/%%m/%%Y')::DATE AS dt_nascimento,
        %s AS ds_genero,
        %s AS ds_cor_raca,
        %s AS ds_grau_instrucao,
        %s AS ds_estado_civil,
        %s AS ds_ocupacao,
        %s AS tp_agremiacao,
        %s AS nm_coligacao,
        %s AS ds_situacao_candidatura,
        %s AS ds_sit_tot_turno,
        TRY_CAST(NR_TURNO AS INTEGER) AS nr_turno,
        TRY_STRPTIME(CAST(DT_ELEICAO AS VARCHAR), '%%d/%%m/%%Y')::DATE AS dt_eleicao,
        BOOL_OR(TRY_CAST(NR_TURNO AS INTEGER) = 2) OVER (PARTITION BY CAST(SQ_CANDIDATO AS VARCHAR)) AS disputou_segundo_turno
      FROM read_parquet('%s')
      WHERE SQ_CANDIDATO IS NOT NULL AND %s IS NOT NULL
    )
    SELECT
      sq_candidato,
      cd_municipio_tse,
      nr_partido,
      cd_cargo,
      ds_cargo,
      nr_candidato,
      nm_candidato,
      nm_urna_candidato,
      sg_uf_nascimento,
      CASE WHEN sg_uf_nascimento IS NOT NULL THEN sg_uf_nascimento = sg_uf_cand ELSE NULL END AS is_candidato_local,
      dt_nascimento,
      CAST(2024 - EXTRACT(YEAR FROM dt_nascimento) AS INTEGER) AS idade_2024,
      ds_genero,
      ds_cor_raca,
      ds_grau_instrucao,
      ds_estado_civil,
      ds_ocupacao,
      tp_agremiacao,
      nm_coligacao,
      ds_situacao_candidatura,
      ds_sit_tot_turno,
      nr_turno AS nr_turno_final,
      disputou_segundo_turno,
      STARTS_WITH(COALESCE(ds_sit_tot_turno, ''), 'ELEITO') AS is_eleito,
      CASE
        WHEN STARTS_WITH(COALESCE(ds_sit_tot_turno, ''), 'ELEITO') THEN 'Eleito'
        WHEN CONTAINS(COALESCE(ds_sit_tot_turno, ''), '2º TURNO') THEN '2º Turno'
        WHEN CONTAINS(COALESCE(ds_sit_tot_turno, ''), 'SUPLENTE') THEN 'Suplente'
        ELSE 'Não Eleito'
      END AS status_eleicao
    FROM base
    QUALIFY ROW_NUMBER() OVER (
      PARTITION BY sq_candidato
      ORDER BY nr_turno DESC NULLS LAST, dt_eleicao DESC NULLS LAST
    ) = 1
  ",
    sql_limpar("DS_CARGO", upper = TRUE),
    sql_limpar("NM_CANDIDATO", upper = TRUE),
    sql_limpar("NM_URNA_CANDIDATO", upper = TRUE),
    sql_limpar("SG_UF_NASCIMENTO", upper = TRUE),
    sql_limpar("DS_GENERO", upper = TRUE),
    sql_limpar("DS_COR_RACA", upper = TRUE),
    sql_limpar("DS_GRAU_INSTRUCAO", upper = TRUE),
    sql_limpar("DS_ESTADO_CIVIL", upper = TRUE),
    sql_limpar("DS_OCUPACAO", upper = TRUE),
    sql_limpar("TP_AGREMIACAO", upper = TRUE),
    sql_limpar("NM_COLIGACAO", upper = TRUE),
    sql_limpar("DS_SITUACAO_CANDIDATURA", upper = TRUE),
    sql_limpar("DS_SIT_TOT_TURNO", upper = TRUE),
    arq_cand_in,
    sql_limpar("NM_CANDIDATO")
  )
  n_cand <- executar_copy_parquet(con, sql_candidato, path(DADOS_PRATA, "dim_candidato.parquet"))
  message("✔ dados/prata/dim_candidato.parquet salvo (", n_cand, " candidatos únicos)")

  # 3. fato_votacao.parquet
  sql_votacao <- sprintf("
    SELECT
      CAST(SQ_CANDIDATO AS VARCHAR) AS sq_candidato,
      LPAD(CAST(CD_MUNICIPIO AS VARCHAR), 5, '0') AS cd_municipio_tse,
      TRY_CAST(NR_TURNO AS INTEGER) AS nr_turno,
      TRY_STRPTIME(CAST(DT_ELEICAO AS VARCHAR), '%%d/%%m/%%Y')::DATE AS dt_eleicao,
      TRY_CAST(NR_ZONA AS INTEGER) AS nr_zona,
      TRY_CAST(QT_VOTOS_NOMINAIS AS INTEGER) AS qt_votos_nominais,
      TRY_CAST(QT_VOTOS_NOMINAIS_VALIDOS AS INTEGER) AS qt_votos_nominais_validos,
      %s AS ds_sit_tot_turno,
      (UPPER(TRIM(CAST(ST_VOTO_EM_TRANSITO AS VARCHAR))) = 'S') AS st_voto_em_transito
    FROM read_parquet('%s')
    WHERE SQ_CANDIDATO IS NOT NULL
      AND TRY_CAST(QT_VOTOS_NOMINAIS AS INTEGER) >= 0
  ",
    sql_limpar("DS_SIT_TOT_TURNO", upper = TRUE),
    arq_vot_in
  )
  n_vot <- executar_copy_parquet(con, sql_votacao, path(DADOS_PRATA, "fato_votacao.parquet"))
  message("✔ dados/prata/fato_votacao.parquet salvo (", n_vot, " registros)")
})
