# ==============================================================================
# GOLD 01: DATAMART DE CANDIDATOS 2024 (MG & SP) -> 100% PARQUET (snake_case)
# ==============================================================================
# Consolida perfil biográfico, finanças, votos e patrimônio por sq_candidato.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

dir_create("03_gold/data")
message("=== [Gold] Construindo Datamart Candidatos 2024 ===")

candidatos <- read_parquet("02_silver/data/tse/candidatos_clean.parquet")

receitas_agg <- open_dataset("02_silver/data/tse/receitas_clean.parquet") %>%
  group_by(sq_candidato) %>%
  summarise(
    total_arrecadado = sum(vr_receita, na.rm = TRUE),
    total_fundo_publico = sum(ifelse(is_fundo_publico, vr_receita, 0), na.rm = TRUE)
  ) %>%
  collect()

despesas_agg <- open_dataset("02_silver/data/tse/despesas_clean.parquet") %>%
  group_by(sq_candidato) %>%
  summarise(total_gasto = sum(vr_despesa_contratada, na.rm = TRUE)) %>%
  collect()

votos_agg <- open_dataset("02_silver/data/tse/votacao_munzona_clean.parquet") %>%
  group_by(sq_candidato) %>%
  summarise(
    total_votos = sum(qt_votos_nominais, na.rm = TRUE),
    qtd_zonas_com_voto = n_distinct(nr_zona)
  ) %>%
  collect()

bens_agg <- read_parquet("02_silver/data/tse/bens_candidatos_clean.parquet")

datamart <- candidatos %>%
  left_join(receitas_agg, by = "sq_candidato") %>%
  left_join(despesas_agg, by = "sq_candidato") %>%
  left_join(votos_agg, by = "sq_candidato") %>%
  left_join(bens_agg, by = "sq_candidato") %>%
  mutate(across(
    c(total_arrecadado, total_fundo_publico, total_gasto, total_votos,
      qtd_zonas_com_voto, total_patrimonio_declarado, qtd_bens_declarados),
    ~replace_na(.x, 0)
  )) %>%
  mutate(
    total_votos = as.integer(total_votos),
    qtd_zonas_com_voto = as.integer(qtd_zonas_com_voto),
    qtd_bens_declarados = as.integer(qtd_bens_declarados),
    pct_fundo_publico = ifelse(total_arrecadado > 0, (total_fundo_publico / total_arrecadado) * 100, 0),
    custo_por_voto = ifelse(total_votos > 0, total_gasto / total_votos, NA_real_),
    roi_votos_por_real = ifelse(total_gasto > 0, total_votos / total_gasto, NA_real_)
  )

write_parquet(datamart, "03_gold/data/datamart_candidatos_2024.parquet", compression = "zstd")
message("✔ datamart_candidatos_2024.parquet salvo (", nrow(datamart), " candidatos, ", ncol(datamart), " colunas)")
