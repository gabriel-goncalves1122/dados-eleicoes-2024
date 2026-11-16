# ==============================================================================
# GOLD 01: DATAMART DE CANDIDATOS 2024 (MG & SP) -> 100% PARQUET
# ==============================================================================

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
  group_by(SQ_CANDIDATO) %>%
  summarise(
    Total_Arrecadado = sum(VR_RECEITA, na.rm = TRUE),
    Total_Fundo_Publico = sum(ifelse(Flag_Dinheiro_Publico, VR_RECEITA, 0), na.rm = TRUE)
  ) %>%
  collect()

despesas_agg <- open_dataset("02_silver/data/tse/despesas_clean.parquet") %>%
  group_by(SQ_CANDIDATO) %>%
  summarise(Total_Gasto = sum(VR_DESPESA_CONTRATADA, na.rm = TRUE)) %>%
  collect()

votos_agg <- open_dataset("02_silver/data/tse/votacao_munzona_clean.parquet") %>%
  group_by(SQ_CANDIDATO) %>%
  summarise(
    Total_Votos = sum(QT_VOTOS_NOMINAIS, na.rm = TRUE),
    Qtd_Zonas_Com_Voto = n_distinct(NR_ZONA)
  ) %>%
  collect()

bens_agg <- read_parquet("02_silver/data/tse/bens_candidatos_clean.parquet")

datamart <- candidatos %>%
  left_join(receitas_agg, by = "SQ_CANDIDATO") %>%
  left_join(despesas_agg, by = "SQ_CANDIDATO") %>%
  left_join(votos_agg, by = "SQ_CANDIDATO") %>%
  left_join(bens_agg, by = "SQ_CANDIDATO") %>%
  mutate(across(
    c(Total_Arrecadado, Total_Fundo_Publico, Total_Gasto, Total_Votos,
      Total_Patrimonio_Declarado, Qtd_Bens_Declarados),
    ~replace_na(.x, 0)
  )) %>%
  mutate(
    Pct_Fundo_Publico = ifelse(Total_Arrecadado > 0, Total_Fundo_Publico / Total_Arrecadado, 0),
    Custo_Por_Voto = ifelse(Total_Votos > 0, Total_Gasto / Total_Votos, NA_real_),
    ROI_Votos_Por_Real = ifelse(Total_Gasto > 0, Total_Votos / Total_Gasto, NA_real_)
  )

write_parquet(datamart, "03_gold/data/datamart_candidatos_2024.parquet", compression = "zstd")
message("✔ datamart_candidatos_2024.parquet salvo (", nrow(datamart), " candidatos)")
