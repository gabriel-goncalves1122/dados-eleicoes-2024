# ==============================================================================
# SCRIPT 01: LIMPEZA PURA - CANDIDATOS E VOTAÇÃO (SEM AGREGAÇÃO)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)

message("Lendo base bruta de Candidatos...")
candidatos_raw <- read_parquet("tse/data/01_raw/parquet/candidatos.parquet")

message("Limpando metadados dos Candidatos...")
candidatos_clean <- candidatos_raw %>%
  # Forçar tipagem do ID
  mutate(SQ_CANDIDATO = as.character(SQ_CANDIDATO)) %>%
  # Selecionar colunas de interesse biográfico e político
  select(SQ_CANDIDATO, NM_CANDIDATO, NM_URNA_CANDIDATO, NR_CPF_CANDIDATO, 
         SG_UF, SG_PARTIDO, DS_CARGO, DS_GENERO, DS_COR_RACA, DS_OCUPACAO, 
         DS_GRAU_INSTRUCAO, DT_NASCIMENTO, DS_SIT_TOT_TURNO) %>%
  # Normalização de Strings (Maiúsculas para facilitar cruzamentos futuros se necessário)
  mutate(across(c(NM_CANDIDATO, NM_URNA_CANDIDATO, DS_OCUPACAO), str_to_upper)) %>%
  # Criar coluna derivada: Idade na eleição (2022)
  mutate(Ano_Nascimento = as.numeric(str_sub(DT_NASCIMENTO, -4)),
         Idade_2022 = 2022 - Ano_Nascimento) %>%
  select(-Ano_Nascimento) %>%
  # Criar flag de eleição
  mutate(Status_Eleicao = ifelse(str_detect(DS_SIT_TOT_TURNO, "ELEITO|MÉDIA"), "Eleito", "Não Eleito")) %>%
  # Tratamento de Nulos e Casos Inválidos
  filter(!is.na(SQ_CANDIDATO), !is.na(NM_CANDIDATO))

write_parquet(candidatos_clean, "tse/data/02_silver/parquet/candidatos_clean.parquet")
write_csv(candidatos_clean, "tse/data/02_silver/csv/candidatos_clean.csv")

message("Processando base de Votos (Sem Agregação - Nível Municipal/Zona)...")
csv_votacao <- "tse/data/01_raw/zips/votacao_candidato_munzona_2022/votacao_candidato_munzona_2022_BRASIL_utf8.csv"

# Ler colunas específicas para não estourar a RAM
votos_dataset <- open_dataset(csv_votacao, format = "csv", delimiter = ";")

votos_query <- votos_dataset %>%
  select(SQ_CANDIDATO, SG_UF, CD_MUNICIPIO, NM_MUNICIPIO, NR_ZONA, QT_VOTOS_NOMINAIS) %>%
  mutate(SQ_CANDIDATO = as.character(SQ_CANDIDATO),
         QT_VOTOS_NOMINAIS = as.integer(QT_VOTOS_NOMINAIS)) %>%
  # Tratamento de Nulos e Outliers (Votos nulos/negativos removidos da base nominal)
  filter(!is.na(SQ_CANDIDATO), !is.na(QT_VOTOS_NOMINAIS), QT_VOTOS_NOMINAIS >= 0)

# Utilizando write_dataset para processar em blocos (Streaming) sem travar a memória
write_dataset(votos_query, "tse/data/02_silver/parquet/votacao_munzona_clean", format = "parquet")
write_dataset(votos_query, "tse/data/02_silver/csv/votacao_munzona_clean", format = "csv")

message("✅ Candidatos e Votação Municipal limpos e salvos com sucesso!")
