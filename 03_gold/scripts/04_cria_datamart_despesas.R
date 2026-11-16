# ==============================================================================
# GOLD 04: DATAMART DE DESPESAS POR CATEGORIA E TEMPO (2024 - MG & SP)
# ==============================================================================
# Agrega as 1,27M de despesas da Silver por UF, cargo, status (eleito vs. não),
# origem da despesa e data, facilitando análises de fluxo e destino dos gastos.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

dir_create("03_gold/data")
message("=== [Gold] Construindo Datamart de Despesas 2024 ===")

cand_meta <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet") %>%
  select(sq_candidato, ds_cargo, is_eleito)

datamart_despesas <- open_dataset("02_silver/data/tse/despesas_clean.parquet") %>%
  select(sq_candidato, sg_uf, dt_despesa, ds_origem_despesa, vr_despesa_contratada) %>%
  collect() %>%
  inner_join(cand_meta, by = "sq_candidato") %>%
  mutate(
    ds_origem_despesa = coalesce(ds_origem_despesa, "Não Especificada")
  ) %>%
  group_by(sg_uf, ds_cargo, is_eleito, ds_origem_despesa, dt_despesa) %>%
  summarise(
    qtd_lancamentos = as.integer(n()),
    total_despesa = sum(vr_despesa_contratada, na.rm = TRUE),
    .groups = "drop"
  )

write_parquet(datamart_despesas, "03_gold/data/datamart_despesas_2024.parquet", compression = "zstd")
message("✔ datamart_despesas_2024.parquet salvo (", nrow(datamart_despesas), " linhas agregadas)")
