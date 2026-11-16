# ==============================================================================
# GOLD 03: INTEGRAÇÃO TSE 2024 + IBGE (CENSO 2022 & PIB) -> 100% PARQUET
# ==============================================================================
# Cruza o Datamart Municipal (TSE 2024) com os indicadores do IBGE (Silver)
# calculando Gaps de Representatividade (Urnas vs. Censo) por gênero e raça.

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

ibge_consolidado <- read_parquet("02_silver/data/ibge/ibge_indicadores.parquet")
depara <- read_parquet("02_silver/data/depara_tse_ibge.parquet")
datamart_tse <- read_parquet("03_gold/data/datamart_municipal_2024.parquet")

datamart_integrado <- datamart_tse %>%
  left_join(depara, by = c("cd_municipio_tse", "sg_uf")) %>%
  left_join(ibge_consolidado, by = "cd_municipio_ibge") %>%
  mutate(
    gasto_campanha_per_capita = total_gasto_campanhas / populacao_2022,
    taxa_comparecimento_estimada = (total_votos_nominais / populacao_2022) * 100,
    # Gaps de Representatividade (pp = % Urnas - % Censo)
    gap_cand_mulheres = pct_cand_mulheres - pct_mulheres_censo,
    gap_eleitos_mulheres = pct_eleitos_mulheres - pct_mulheres_censo,
    gap_cand_negros_indigenas = pct_cand_negros_indigenas - pct_negros_indigenas_censo,
    gap_eleitos_negros_indigenas = pct_eleitos_negros_indigenas - pct_negros_indigenas_censo,
    gap_eleitos_branca = pct_eleitos_branca - pct_branca_censo,
    gap_eleitos_preta = pct_eleitos_preta - pct_preta_censo,
    gap_eleitos_parda = pct_eleitos_parda - pct_parda_censo,
    porte_municipio = case_when(
      populacao_2022 < 20000 ~ "Pequeno Porte I (<20k)",
      populacao_2022 < 50000 ~ "Pequeno Porte II (20k-50k)",
      populacao_2022 < 100000 ~ "Médio Porte (50k-100k)",
      populacao_2022 < 500000 ~ "Grande Porte (100k-500k)",
      TRUE ~ "Metrópole (>500k)"
    )
  )

write_parquet(datamart_integrado, "03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet", compression = "zstd")
message("🎉 datamart_eleitoral_socioeconomico_2024.parquet salvo (", nrow(datamart_integrado), " municípios, ", ncol(datamart_integrado), " colunas)")
