# ==============================================================================
# SCRIPT 01 (VIS): EXPLORAÇÃO DOS DADOS DO IBGE
# ==============================================================================
# IMPORTANTE: Apenas visualização. Os dados já vêm limpos da pasta processed.
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(reactable)

message("Carregando Dados Processados do IBGE...")
ibge_clean <- read_parquet("ibge/data/processed/parquet/ibge_indicadores.parquet")

print(reactable(ibge_clean %>% head(100), 
                columns = list(
                  pib = colDef(format = colFormat(currency = "BRL")),
                  PIB_Per_Capita = colDef(format = colFormat(currency = "BRL"))
                ),
                searchable = TRUE, 
                striped = TRUE))
