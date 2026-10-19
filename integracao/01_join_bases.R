# ==============================================================================
# SCRIPT 01: INTEGRAÇÃO RELACIONAL (TSE + IBGE)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)

message("=== Iniciando Integração ===")

# Base do IBGE é simples
ibge <- read_parquet("ibge/data/raw/populacao_2022.parquet") %>%
  inner_join(read_parquet("ibge/data/raw/pib_municipal.parquet"), by = "codigo_ibge")

# A base de votação do TSE usa um código municipal próprio (CD_MUNICIPIO).
# Precisaremos de uma tabela "De-Para" entre Código TSE e Código IBGE 
# (ou cruzar por Nome do Município + UF, usando tratamento de strings).
# Isso será implementado quando toda a base de votação terminar de baixar!

message("Script de integração criado com sucesso. Aguardando download completo do TSE.")
