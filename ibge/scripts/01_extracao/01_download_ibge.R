# ==============================================================================
# SCRIPT 01: COLETA DE DADOS IBGE (SIDRA)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(sidrar)
library(arrow)
library(fs)

# Garante que as pastas de raw existem
dir_create("ibge/data/raw/parquet")
dir_create("ibge/data/raw/csv")

message("=== Iniciando Coleta IBGE ===")

# ------------------------------------------------------------------------------
# 1. POPULAÇÃO MUNICIPAL (Censo 2022)
# ------------------------------------------------------------------------------
message("Baixando População Municipal (IBGE)...")
populacao <- get_sidra(api = "/t/4709/n6/all/v/93/p/2022/c86/2776/d/v93%201") %>%
  select(codigo_ibge = `Município (Código)`, populacao = Valor) %>%
  mutate(populacao = as.numeric(populacao))

write_parquet(populacao, "ibge/data/raw/parquet/populacao_2022.parquet")
write_csv(populacao, "ibge/data/raw/csv/populacao_2022.csv")

# ------------------------------------------------------------------------------
# 2. PIB MUNICIPAL (Mais recente disponível no SIDRA)
# ------------------------------------------------------------------------------
message("Baixando PIB Municipal (IBGE)...")
pib <- get_sidra(api = "/t/5938/n6/all/v/37/p/last%201/d/v37%200") %>%
  select(codigo_ibge = `Município (Código)`, pib = Valor) %>%
  mutate(pib = as.numeric(pib))

write_parquet(pib, "ibge/data/raw/parquet/pib_municipal.parquet")
write_csv(pib, "ibge/data/raw/csv/pib_municipal.csv")

message("✅ Coleta IBGE finalizada!")
