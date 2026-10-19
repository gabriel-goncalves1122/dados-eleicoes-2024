# ==============================================================================
# SCRIPT 03: LIMPEZA PURA - DESPESAS (SEM AGREGAÇÃO)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)

csv_despesas <- "tse/data/01_raw/zips/prestacao_de_contas_eleitorais_candidatos_2022/despesas_contratadas_candidatos_2022_BRASIL_utf8.csv"

message("Iniciando Streaming do arquivo bruto de Despesas...")
despesas_dataset <- open_dataset(csv_despesas, format = "csv", delimiter = ";")

message("Configurando pipeline de Limpeza...")
despesas_query <- despesas_dataset %>%
  select(SQ_CANDIDATO, DT_DESPESA, DS_ORIGEM_DESPESA, DS_DESPESA, 
         VR_DESPESA_CONTRATADA, NR_CPF_CNPJ_FORNECEDOR, NM_FORNECEDOR) %>%
  mutate(
    # IDs
    SQ_CANDIDATO = as.character(SQ_CANDIDATO),
    NR_CPF_CNPJ_FORNECEDOR = as.character(NR_CPF_CNPJ_FORNECEDOR),
    # Valores monetários
    VR_DESPESA_CONTRATADA = as.numeric(str_replace_all(VR_DESPESA_CONTRATADA, ",", "."))
  ) %>%
  # Tratamento de Nulos e Outliers (Ignorar despesas sem valor ou negativas)
  filter(!is.na(SQ_CANDIDATO), !is.na(VR_DESPESA_CONTRATADA), VR_DESPESA_CONTRATADA >= 0)

message("Executando limpeza e salvando blocos...")
write_dataset(despesas_query, "tse/data/02_silver/parquet/despesas_clean", format = "parquet")
write_dataset(despesas_query, "tse/data/02_silver/csv/despesas_clean", format = "csv")

message("✅ Base de Despesas limpa (linha-a-linha) e salva nas pastas processed via Arrow Streaming!")
