# ==============================================================================
# GOLD 03: INTEGRAÇÃO TSE 2024 + IBGE (CENSO 2022 & PIB) -> 100% PARQUET
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
message("=== [Gold] Integrando TSE 2024 + IBGE (MG & SP) ===")

ibge_consolidado <- read_parquet("02_silver/data/ibge/ibge_indicadores.parquet") %>%
  mutate(codigo_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"))

depara <- read_parquet("01_bronze/data/depara_tse_ibge.parquet")

datamart_tse <- read_parquet("03_gold/data/datamart_municipal_2024.parquet") %>%
  mutate(CD_MUNICIPIO = str_pad(as.character(CD_MUNICIPIO), 5, "left", "0"))

datamart_integrado <- datamart_tse %>%
  left_join(depara, by = c("CD_MUNICIPIO" = "codigo_tse", "SG_UF" = "uf")) %>%
  left_join(ibge_consolidado, by = "codigo_ibge") %>%
  mutate(
    Gasto_Campanha_Per_Capita = Total_Gasto_Campanhas / populacao,
    Taxa_Comparecimento_Estimada = Total_Votos_Nominais / populacao,
    Gap_Representatividade_Mulheres = Pct_Cand_Mulheres - pct_mulheres_censo,
    Gap_Representatividade_Negros_Indigenas = Pct_Cand_Negros_Indigenas - pct_negros_indigenas_censo,
    Porte_Municipio = case_when(
      populacao < 20000 ~ "Pequeno Porte I (<20k)",
      populacao < 50000 ~ "Pequeno Porte II (20k-50k)",
      populacao < 100000 ~ "Médio Porte (50k-100k)",
      populacao < 500000 ~ "Grande Porte (100k-500k)",
      TRUE ~ "Metrópole (>500k)"
    )
  )

write_parquet(datamart_integrado, "03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet", compression = "zstd")
message("🎉 datamart_eleitoral_socioeconomico_2024.parquet salvo (", nrow(datamart_integrado), " municípios, ", ncol(datamart_integrado), " colunas)")
