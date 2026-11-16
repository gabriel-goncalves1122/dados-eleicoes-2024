# ==============================================================================
# SILVER 02: LIMPEZA E TIPAGEM FORTE - FINANÇAS E PATRIMÔNIO 2024
# ==============================================================================
# Padrão de mercado: snake_case, Float64 para valores monetários, Date32 para
# datas, Boolean para flags e remoção de sentinelas (#NULO#, -1, -3, -4).

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

dir_create("02_silver/data/tse")
message("=== [Silver] Higienizando e Tipando Finanças e Bens 2024 ===")

limpar_sentinela <- function(x) {
  x_trim <- str_squish(as.character(x))
  if_else(x_trim %in% c("#NULO#", "#NULO", "#NE#", "#NE", "-1", "-3", "-4", ""), NA_character_, x_trim)
}

# 1. Receitas de Campanha
receitas_clean <- open_dataset("01_bronze/data/tse/receitas.parquet") %>%
  select(
    sq_candidato = SQ_CANDIDATO,
    sg_uf = SG_UF,
    cd_municipio_tse = SG_UE,
    dt_receita = DT_RECEITA,
    ds_fonte_receita = DS_FONTE_RECEITA,
    ds_origem_receita = DS_ORIGEM_RECEITA,
    ds_natureza_receita = DS_NATUREZA_RECEITA,
    ds_especie_receita = DS_ESPECIE_RECEITA,
    vr_receita = VR_RECEITA,
    nr_cpf_cnpj_doador = NR_CPF_CNPJ_DOADOR,
    nm_doador = NM_DOADOR
  ) %>%
  collect() %>%
  mutate(
    sq_candidato = as.character(sq_candidato),
    cd_municipio_tse = str_pad(as.character(cd_municipio_tse), width = 5, side = "left", pad = "0"),
    dt_receita = as.Date(dt_receita, format = "%d/%m/%Y"),
    vr_receita = suppressWarnings(as.numeric(str_replace_all(vr_receita, ",", "."))),
    nr_cpf_cnpj_doador = limpar_sentinela(nr_cpf_cnpj_doador),
    nm_doador = str_to_upper(limpar_sentinela(nm_doador)),
    ds_fonte_receita = limpar_sentinela(ds_fonte_receita),
    ds_origem_receita = limpar_sentinela(ds_origem_receita),
    is_fundo_publico = str_detect(coalesce(ds_fonte_receita, ""), "(?i)FUNDO ESPECIAL|FUNDO PARTID")
  ) %>%
  filter(!is.na(sq_candidato), !is.na(vr_receita), vr_receita >= 0)

write_parquet(receitas_clean, "02_silver/data/tse/receitas_clean.parquet", compression = "zstd")
message("✔ receitas_clean.parquet salvo (", nrow(receitas_clean), " registros)")

# 2. Despesas Contratadas
despesas_clean <- open_dataset("01_bronze/data/tse/despesas.parquet") %>%
  select(
    sq_candidato = SQ_CANDIDATO,
    sg_uf = SG_UF,
    cd_municipio_tse = SG_UE,
    dt_despesa = DT_DESPESA,
    ds_origem_despesa = DS_ORIGEM_DESPESA,
    ds_despesa = DS_DESPESA,
    ds_tipo_documento = DS_TIPO_DOCUMENTO,
    vr_despesa_contratada = VR_DESPESA_CONTRATADA,
    nr_cpf_cnpj_fornecedor = NR_CPF_CNPJ_FORNECEDOR,
    nm_fornecedor = NM_FORNECEDOR
  ) %>%
  collect() %>%
  mutate(
    sq_candidato = as.character(sq_candidato),
    cd_municipio_tse = str_pad(as.character(cd_municipio_tse), width = 5, side = "left", pad = "0"),
    dt_despesa = as.Date(dt_despesa, format = "%d/%m/%Y"),
    vr_despesa_contratada = suppressWarnings(as.numeric(str_replace_all(vr_despesa_contratada, ",", "."))),
    nr_cpf_cnpj_fornecedor = limpar_sentinela(nr_cpf_cnpj_fornecedor),
    nm_fornecedor = str_to_upper(limpar_sentinela(nm_fornecedor)),
    ds_origem_despesa = limpar_sentinela(ds_origem_despesa)
  ) %>%
  filter(!is.na(sq_candidato), !is.na(vr_despesa_contratada), vr_despesa_contratada >= 0)

write_parquet(despesas_clean, "02_silver/data/tse/despesas_clean.parquet", compression = "zstd")
message("✔ despesas_clean.parquet salvo (", nrow(despesas_clean), " registros)")

# 3. Bens Declarados (agregado por candidato)
bens_candidatos_clean <- open_dataset("01_bronze/data/tse/bens.parquet") %>%
  select(sq_candidato = SQ_CANDIDATO, vr_bem = VR_BEM_CANDIDATO) %>%
  collect() %>%
  mutate(
    sq_candidato = as.character(sq_candidato),
    vr_bem = suppressWarnings(as.numeric(str_replace_all(vr_bem, ",", ".")))
  ) %>%
  filter(!is.na(sq_candidato), !is.na(vr_bem), vr_bem >= 0) %>%
  group_by(sq_candidato) %>%
  summarise(
    total_patrimonio_declarado = sum(vr_bem, na.rm = TRUE),
    qtd_bens_declarados = as.integer(n()),
    .groups = "drop"
  )

write_parquet(bens_candidatos_clean, "02_silver/data/tse/bens_candidatos_clean.parquet", compression = "zstd")
message("✔ bens_candidatos_clean.parquet salvo (", nrow(bens_candidatos_clean), " candidatos)")
