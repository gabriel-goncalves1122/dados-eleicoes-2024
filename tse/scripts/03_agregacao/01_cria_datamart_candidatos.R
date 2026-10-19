# ==============================================================================
# SCRIPT 01: CAMADA GOLD - DATAMART DE CANDIDATOS (AGREGAÇÃO MASTER)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)

message("1. Carregando dados de Candidatos (Base principal)...")
candidatos <- open_dataset("tse/data/02_silver/parquet/candidatos_clean.parquet") %>%
  collect() %>%
  
  mutate(Status_Eleicao = case_when(
    str_detect(DS_SIT_TOT_TURNO, "^ELEITO$|MÉDIA|QUOCIENTE") ~ "Eleito",
    TRUE ~ "Não Eleito"
  ))

message("2. Agrupando Receitas por Candidato (Via Arrow Engine)...")
receitas_agg <- open_dataset("tse/data/02_silver/parquet/receitas_clean.parquet") %>%
  group_by(SQ_CANDIDATO) %>%
  summarise(
    Total_Arrecadado = sum(VR_RECEITA, na.rm = TRUE),
    Total_Fundo_Publico = sum(ifelse(Flag_Dinheiro_Publico, VR_RECEITA, 0), na.rm = TRUE)
  ) %>%
  collect()

message("3. Agrupando Despesas por Candidato (Via Arrow Engine)...")
despesas_agg <- open_dataset("tse/data/02_silver/parquet/despesas_clean.parquet") %>%
  group_by(SQ_CANDIDATO) %>%
  summarise(
    Total_Gasto = sum(VR_DESPESA_CONTRATADA, na.rm = TRUE)
  ) %>%
  collect()

message("4. Agrupando Votação Total por Candidato (Via Arrow Engine)...")
# Essa operação vai varrer os 5GB do disco de forma otimizada
votos_agg <- open_dataset("tse/data/02_silver/parquet/votacao_munzona_clean.parquet") %>%
  group_by(SQ_CANDIDATO) %>%
  summarise(
    Total_Votos = sum(QT_VOTOS_NOMINAIS, na.rm = TRUE),
    Qtd_Municipios_Com_Voto = n_distinct(CD_MUNICIPIO)
  ) %>%
  collect()

message("5. Construindo o Datamart Analítico (JOINs)...")
datamart <- candidatos %>%
  left_join(receitas_agg, by = "SQ_CANDIDATO") %>%
  left_join(despesas_agg, by = "SQ_CANDIDATO") %>%
  left_join(votos_agg, by = "SQ_CANDIDATO") %>%
  # Tratamento de NAs gerados pelo Join (quem não teve despesa ou voto vira 0)
  mutate(across(c(Total_Arrecadado, Total_Fundo_Publico, Total_Gasto, Total_Votos, Qtd_Municipios_Com_Voto), ~replace_na(.x, 0))) %>%
  # Criando Métricas de Negócio (Camada Gold)
  mutate(
    Pct_Fundo_Publico = ifelse(Total_Arrecadado > 0, Total_Fundo_Publico / Total_Arrecadado, 0),
    Custo_Por_Voto = ifelse(Total_Votos > 0, Total_Gasto / Total_Votos, NA) # NA para quem não teve voto mas teve gasto
  )

message("6. Salvando Datamart Ouro...")
write_parquet(datamart, "tse/data/03_gold/parquet/datamart_candidatos_2022.parquet")
write_csv(datamart, "tse/data/03_gold/csv/datamart_candidatos_2022.csv")

message("✅ Datamart gerado com sucesso!")
