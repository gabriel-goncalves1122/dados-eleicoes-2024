# ==============================================================================
# SCRIPT 01: LIMPEZA DO IBGE (POPULAÇÃO E PIB)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)

message("Lendo bases brutas do IBGE...")
populacao <- read_parquet("ibge/data/raw/parquet/populacao_2022.parquet")
pib <- read_parquet("ibge/data/raw/parquet/pib_municipal.parquet")

message("Limpando e juntando os indicadores...")
ibge_clean <- populacao %>%
  inner_join(pib, by = "codigo_ibge") %>%
  mutate(PIB_Per_Capita = pib / populacao) %>%
  arrange(desc(PIB_Per_Capita))

write_parquet(ibge_clean, "ibge/data/processed/parquet/ibge_indicadores.parquet")
write_csv(ibge_clean, "ibge/data/processed/csv/ibge_indicadores.csv")
message("✅ Base do IBGE limpa, unificada e salva em processed/parquet e processed/csv!")
