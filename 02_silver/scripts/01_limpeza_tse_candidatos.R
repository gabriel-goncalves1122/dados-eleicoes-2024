# ==============================================================================
# SILVER 01: LIMPEZA E TIPAGEM FORTE - CANDIDATOS E VOTAÇÃO 2024
# ==============================================================================
# Padrão de mercado: snake_case, tipos nativos (Date, Int16/32, Boolean),
# remoção de sentinelas (#NULO#, -1, -3, -4) e deduplicação por sq_candidato.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

dir_create("02_silver/data/tse")
message("=== [Silver] Higienizando e Tipando Candidatos e Votação 2024 ===")

limpar_sentinela <- function(x) {
  x_trim <- str_squish(as.character(x))
  if_else(x_trim %in% c("#NULO#", "#NULO", "#NE#", "#NE", "-1", "-3", "-4", ""), NA_character_, x_trim)
}

# 1. Candidatos (MG & SP) — deduplicado por sq_candidato (turno mais recente)
candidatos_clean <- open_dataset("01_bronze/data/tse/candidatos.parquet") %>%
  select(
    sq_candidato = SQ_CANDIDATO,
    nr_candidato = NR_CANDIDATO,
    nm_candidato = NM_CANDIDATO,
    nm_urna_candidato = NM_URNA_CANDIDATO,
    sg_uf = SG_UF,
    cd_municipio_tse = SG_UE,
    nm_municipio = NM_UE,
    cd_cargo = CD_CARGO,
    ds_cargo = DS_CARGO,
    nr_partido = NR_PARTIDO,
    sg_partido = SG_PARTIDO,
    nm_partido = NM_PARTIDO,
    tp_agremiacao = TP_AGREMIACAO,
    sg_federacao = SG_FEDERACAO,
    ds_genero = DS_GENERO,
    ds_cor_raca = DS_COR_RACA,
    ds_grau_instrucao = DS_GRAU_INSTRUCAO,
    ds_estado_civil = DS_ESTADO_CIVIL,
    ds_ocupacao = DS_OCUPACAO,
    dt_nascimento = DT_NASCIMENTO,
    nr_turno = NR_TURNO,
    dt_eleicao = DT_ELEICAO,
    ds_sit_tot_turno = DS_SIT_TOT_TURNO
  ) %>%
  collect() %>%
  mutate(
    sq_candidato = as.character(sq_candidato),
    nr_candidato = as.character(nr_candidato),
    cd_municipio_tse = str_pad(as.character(cd_municipio_tse), width = 5, side = "left", pad = "0"),
    nm_municipio = str_to_upper(str_squish(nm_municipio)),
    nm_candidato = str_to_upper(str_squish(nm_candidato)),
    nm_urna_candidato = str_to_upper(str_squish(nm_urna_candidato)),
    cd_cargo = as.integer(cd_cargo),
    nr_partido = as.integer(nr_partido),
    nr_turno = as.integer(nr_turno),
    sg_federacao = limpar_sentinela(sg_federacao),
    ds_genero = limpar_sentinela(ds_genero),
    ds_cor_raca = limpar_sentinela(ds_cor_raca),
    ds_grau_instrucao = limpar_sentinela(ds_grau_instrucao),
    ds_estado_civil = limpar_sentinela(ds_estado_civil),
    ds_ocupacao = str_to_upper(limpar_sentinela(ds_ocupacao)),
    dt_nascimento = as.Date(dt_nascimento, format = "%d/%m/%Y"),
    dt_eleicao = as.Date(dt_eleicao, format = "%d/%m/%Y"),
    idade_2024 = as.integer(2024L - as.integer(format(dt_nascimento, "%Y"))),
    ds_sit_tot_turno = limpar_sentinela(ds_sit_tot_turno),
    is_eleito = str_detect(coalesce(ds_sit_tot_turno, ""), "ELEITO|MÉDIA|QUOCIENTE"),
    status_eleicao = case_when(
      is_eleito ~ "Eleito",
      str_detect(coalesce(ds_sit_tot_turno, ""), "2º TURNO") ~ "2º Turno",
      str_detect(coalesce(ds_sit_tot_turno, ""), "SUPLENTE") ~ "Suplente",
      TRUE ~ "Não Eleito"
    )
  ) %>%
  filter(!is.na(sq_candidato), !is.na(nm_candidato)) %>%
  arrange(sq_candidato, desc(nr_turno), desc(dt_eleicao)) %>%
  distinct(sq_candidato, .keep_all = TRUE)

write_parquet(candidatos_clean, "02_silver/data/tse/candidatos_clean.parquet", compression = "zstd")
message("✔ candidatos_clean.parquet salvo (", nrow(candidatos_clean), " únicos)")

# 2. Votação Nominal MunZona (MG & SP)
votacao_clean <- open_dataset("01_bronze/data/tse/votacao.parquet") %>%
  select(
    nr_turno = NR_TURNO,
    dt_eleicao = DT_ELEICAO,
    sg_uf = SG_UF,
    cd_municipio_tse = CD_MUNICIPIO,
    nm_municipio = NM_MUNICIPIO,
    nr_zona = NR_ZONA,
    cd_cargo = CD_CARGO,
    ds_cargo = DS_CARGO,
    sq_candidato = SQ_CANDIDATO,
    nr_candidato = NR_CANDIDATO,
    qt_votos_nominais = QT_VOTOS_NOMINAIS
  ) %>%
  collect() %>%
  mutate(
    sq_candidato = as.character(sq_candidato),
    cd_municipio_tse = str_pad(as.character(cd_municipio_tse), width = 5, side = "left", pad = "0"),
    nm_municipio = str_to_upper(str_squish(nm_municipio)),
    nr_turno = as.integer(nr_turno),
    nr_zona = as.integer(nr_zona),
    cd_cargo = as.integer(cd_cargo),
    qt_votos_nominais = as.integer(qt_votos_nominais),
    dt_eleicao = as.Date(dt_eleicao, format = "%d/%m/%Y")
  ) %>%
  filter(!is.na(sq_candidato), !is.na(qt_votos_nominais), qt_votos_nominais >= 0L)

write_parquet(votacao_clean, "02_silver/data/tse/votacao_munzona_clean.parquet", compression = "zstd")
message("✔ votacao_munzona_clean.parquet salvo (", nrow(votacao_clean), " registros)")
