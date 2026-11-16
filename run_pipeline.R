# ==============================================================================
# ORQUESTRADOR CENTRAL: PIPELINE MEDALHÃO 100% PARQUET (TSE 2024 + IBGE)
# ==============================================================================
# Uso no RStudio:
#   source("run_pipeline.R")
#   executar_pipeline("tudo")     # Bronze -> Silver -> Gold -> Catálogo
#   executar_pipeline("bronze")   # Ingestão direta para Parquet
#   executar_pipeline("silver")   # Higienização e consolidação colunar
#   executar_pipeline("gold")     # Construção dos Datamarts finais
#   executar_pipeline("catalog")  # Atualização de metadados e dicionários
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

executar_script_com_timer <- function(script_path, descricao) {
  message("\n-----------------------------------------------------------------")
  message("▶ Executando: ", descricao, " [", script_path, "]")
  inicio <- Sys.time()

  sucesso <- tryCatch({
    source(script_path, local = FALSE)
    TRUE
  }, error = function(e) {
    message("❌ ERRO ao executar ", script_path, ": ", e$message)
    FALSE
  })

  duracao <- round(as.numeric(difftime(Sys.time(), inicio, units = "secs")), 1)
  if (sucesso) message("✔ Concluído em ", duracao, "s.")
  sucesso
}

executar_pipeline <- function(etapa = "tudo") {
  etapa <- str_to_lower(etapa)
  inicio_total <- Sys.time()

  message("=================================================================")
  message("🚀 INICIANDO ESTEIRA MEDALHÃO 100% PARQUET (Etapa: ", toupper(etapa), ")")
  message("=================================================================")

  if (etapa %in% c("tudo", "all", "bronze", "01_bronze")) {
    message("\n🥉 === CAMADA 01: BRONZE (INGESTÃO PARQUET) ===")
    executar_script_com_timer("01_bronze/scripts/03_ingestao_depara.R", "De-Para TSE <-> IBGE")
    executar_script_com_timer("01_bronze/scripts/02_ingestao_ibge.R", "IBGE Censo 2022 + PIB Setorial")
    executar_script_com_timer("01_bronze/scripts/01_ingestao_tse.R", "TSE 2024 (MG & SP)")
  }

  if (etapa %in% c("tudo", "all", "silver", "02_silver")) {
    message("\n🥈 === CAMADA 02: SILVER (HIGIENIZAÇÃO COLUNAR) ===")
    executar_script_com_timer("02_silver/scripts/03_limpeza_ibge.R", "Consolidação IBGE")
    executar_script_com_timer("02_silver/scripts/01_limpeza_tse_candidatos.R", "Candidatos e Votação TSE")
    executar_script_com_timer("02_silver/scripts/02_limpeza_tse_financas.R", "Receitas, Despesas e Bens TSE")
  }

  if (etapa %in% c("tudo", "all", "gold", "03_gold")) {
    message("\n🥇 === CAMADA 03: GOLD (DATAMARTS ANALÍTICOS) ===")
    executar_script_com_timer("03_gold/scripts/01_cria_datamart_candidatos.R", "Datamart Candidatos 2024")
    executar_script_com_timer("03_gold/scripts/02_cria_datamart_municipal.R", "Datamart Municipal 2024")
    executar_script_com_timer("03_gold/scripts/03_join_bases_integracao.R", "Datamart Integrado TSE + IBGE")
    executar_script_com_timer("03_gold/scripts/04_cria_datamart_despesas.R", "Datamart Despesas 2024")
  }

  if (etapa %in% c("tudo", "all", "catalog", "docs")) {
    message("\n📚 === GOVERNANÇA: DATA CATALOG ===")
    executar_script_com_timer("03_gold/docs/01_gera_metadados.R", "Catálogo e Metadados Parquet")
  }

  duracao_total <- round(as.numeric(difftime(Sys.time(), inicio_total, units = "mins")), 2)
  message("\n🏁 PIPELINE FINALIZADO em ", duracao_total, " minutos.")
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) executar_pipeline(args[1])
