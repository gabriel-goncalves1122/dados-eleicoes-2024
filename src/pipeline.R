# ==============================================================================
# ORQUESTRADOR CENTRAL: PIPELINE MEDALHÃO 100% PARQUET (TSE 2024 + IBGE - BRASIL)
# ==============================================================================
# Uso no terminal ou RStudio:
#   Rscript src/pipeline.R tudo       # Ingestão -> Limpeza -> Modelagem -> Catálogo
#   Rscript src/pipeline.R ingestao   # Camada Bronze (TSE 27 UFs + IBGE + De-Para)
#   Rscript src/pipeline.R limpeza    # Camada Prata (higienização colunar)
#   Rscript src/pipeline.R modelagem  # Camada Ouro (Datamarts analíticos)
#   Rscript src/pipeline.R catalogo   # Dicionários de dados e metadados JSON/MD
# ==============================================================================

if (file.exists("src/config.R")) {
  source("src/config.R")
} else if (file.exists("../config.R")) {
  source("../config.R")
} else {
  source("Gabriel_Goncalves/src/config.R")
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

resumir_tamanho_camadas <- function(pastas = c(DADOS_BRONZE, DADOS_PRATA, DADOS_OURO)) {
  message("\n📊 === DIAGNÓSTICO DE VOLUMETRIA E ESPAÇO EM DISCO ===")
  for (p in pastas) {
    if (dir_exists(p)) {
      arqs <- dir_info(p, recurse = TRUE, type = "file") %>%
        filter(str_ends(path, "\\.parquet"))
      total_mb <- round(sum(as.numeric(arqs$size), na.rm = TRUE) / (1024^2), 2)
      message("  • ", p, ": ", nrow(arqs), " arquivo(s) .parquet | ", total_mb, " MB")
    }
  }
}

executar_pipeline <- function(etapa = "tudo") {
  etapa <- str_to_lower(etapa)
  inicio_total <- Sys.time()

  message("=================================================================")
  message("🚀 INICIANDO ESTEIRA MEDALHÃO 100% PARQUET (Etapa: ", toupper(etapa), ")")
  message("=================================================================")

  if (etapa %in% c("tudo", "all", "ingestao", "bronze")) {
    message("\n🥉 === CAMADA BRONZE: INGESTÃO (BRASIL) ===")
    ok <- executar_script_com_timer("src/ingestao/ingestao_depara.R", "De-Para TSE <-> IBGE (Brasil)") &&
          executar_script_com_timer("src/ingestao/ingestao_ibge.R", "IBGE Censo 2022 + PIB Setorial (Brasil)") &&
          executar_script_com_timer("src/ingestao/ingestao_tse.R", "TSE 2024 (27 UFs)")
    if (!ok) stop("❌ Pipeline interrompido por falha na camada Bronze.")
  }

  if (etapa %in% c("tudo", "all", "limpeza", "prata", "silver")) {
    message("\n🥈 === CAMADA PRATA: LIMPEZA E TIPAGEM (BRASIL) ===")
    ok <- executar_script_com_timer("src/limpeza/limpeza_ibge.R", "Consolidação IBGE (Brasil)") &&
          executar_script_com_timer("src/limpeza/limpeza_tse_candidatos.R", "Candidatos e Votação TSE (27 UFs)") &&
          executar_script_com_timer("src/limpeza/limpeza_tse_financas.R", "Receitas, Despesas e Bens TSE (27 UFs)")
    if (!ok) stop("❌ Pipeline interrompido por falha na camada Prata.")
  }

  if (etapa %in% c("tudo", "all", "modelagem", "ouro", "gold")) {
    message("\n🥇 === CAMADA OURO: DATAMARTS TEMÁTICOS ENXUTOS (BRASIL) ===")
    ok <- executar_script_com_timer("src/modelagem/ouro_pca_municipios.R", "Ouro 01 - PCA e Tipologia Municipal") &&
          executar_script_com_timer("src/modelagem/ouro_representatividade_municipal.R", "Ouro 02 - Representatividade e Financiamento") &&
          executar_script_com_timer("src/modelagem/ouro_eficiencia_anomalias_candidatos.R", "Ouro 03 - Eficiência, Anomalias e Dobradinhas") &&
          executar_script_com_timer("src/modelagem/ouro_patrimonio_composicao.R", "Ouro 04 - Composição Patrimonial") &&
          executar_script_com_timer("src/modelagem/ouro_estrutura_gastos_campanha.R", "Ouro 05 - Estrutura de Gastos de Campanha") &&
          executar_script_com_timer("src/modelagem/ouro_centralizacao_partidaria.R", "Ouro 06 - Centralização Partidária") &&
          executar_script_com_timer("src/modelagem/ouro_concentracao_zonas.R", "Ouro 07a - Concentração Territorial (HHI)") &&
          executar_script_com_timer("src/modelagem/ouro_fornecedores_rede.R", "Ouro 07b - Rede de Fornecedores")
    if (!ok) stop("❌ Pipeline interrompido por falha na camada Ouro.")
  }

  if (etapa %in% c("tudo", "all", "catalogo", "docs")) {
    message("\n📚 === GOVERNANÇA: DATA CATALOG ===")
    ok <- executar_script_com_timer("docs/catalogo/gera_metadados.R", "Catálogo e Metadados Parquet")
    if (!ok) stop("❌ Pipeline interrompido por falha na geração de catálogo.")
  }

  resumir_tamanho_camadas()
  duracao_total <- round(as.numeric(difftime(Sys.time(), inicio_total, units = "mins")), 2)
  message("\n🏁 PIPELINE FINALIZADO em ", duracao_total, " minutos.")
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) executar_pipeline(args[1])
