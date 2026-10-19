# ==============================================================================
# SCRIPT 02: LIMPEZA PURA - RECEITAS (SEM AGREGAÇÃO)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)

# Lemos a versão convertida para UTF-8 via Bash para suportar o Arrow Streaming
csv_receitas <- "tse/data/01_raw/zips/prestacao_de_contas_eleitorais_candidatos_2022/receitas_candidatos_2022_BRASIL_utf8.csv"

message("Iniciando Streaming do arquivo bruto de Receitas...")
# open_dataset não carrega os dados para a RAM. Ele cria um mapa do arquivo.
receitas_dataset <- open_dataset(csv_receitas, format = "csv", delimiter = ";")

message("Configurando pipeline de Limpeza...")
receitas_query <- receitas_dataset %>%
  select(SQ_CANDIDATO, DT_RECEITA, DS_FONTE_RECEITA, DS_NATUREZA_RECEITA, 
         DS_ESPECIE_RECEITA, VR_RECEITA, NR_CPF_CNPJ_DOADOR, NM_DOADOR) %>%
  mutate(
    # IDs fortes
    SQ_CANDIDATO = as.character(SQ_CANDIDATO),
    NR_CPF_CNPJ_DOADOR = as.character(NR_CPF_CNPJ_DOADOR),
    # Valores monetários
    VR_RECEITA = as.numeric(str_replace_all(VR_RECEITA, ",", ".")),
    # Flag Analítica
    Flag_Dinheiro_Publico = str_detect(DS_FONTE_RECEITA, "(?i)FUNDO ESPECIAL|FUNDO PARTIDARIO")
  ) %>%
  # Tratamento de Nulos e Outliers (Ignorar receitas vazias ou negativas que possam ser estornos sujos)
  filter(!is.na(SQ_CANDIDATO), !is.na(VR_RECEITA), VR_RECEITA >= 0)

message("Executando limpeza e salvando blocos...")
# Streaming: Lê o CSV, aplica a limpeza bloco por bloco e salva instantaneamente (Uso 0 de RAM)
write_dataset(receitas_query, "tse/data/02_silver/parquet/receitas_clean", format = "parquet")
write_dataset(receitas_query, "tse/data/02_silver/csv/receitas_clean", format = "csv")

message("✅ Base de Receitas limpa (linha-a-linha) e salva nas pastas processed via Arrow Streaming!")
