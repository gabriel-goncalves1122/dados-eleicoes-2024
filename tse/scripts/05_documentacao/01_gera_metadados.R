# ==============================================================================
# SCRIPT DE DOCUMENTAÇÃO: DATA CATALOG E METADADOS
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(jsonlite)

# Função para extrair metadados de uma base
extrair_metadados <- function(path_to_dataset, layer_name) {
  # Tenta abrir o dataset (funciona para arquivos individuais ou pastas particionadas)
  ds <- tryCatch({
    open_dataset(path_to_dataset)
  }, error = function(e) return(NULL))
  
  if(is.null(ds)) return(NULL)
  
  nome_base <- basename(path_to_dataset)
  
  # Extrair tipos das colunas
  esquema <- ds$schema
  colunas_info <- lapply(names(esquema), function(col_name) {
    list(
      coluna = col_name,
      tipo = esquema$GetFieldByName(col_name)$type$ToString()
    )
  })
  
  # Contagem total (extremamente rápido via Arrow)
  qtd_linhas <- nrow(ds)
  qtd_colunas <- ncol(ds)
  
  list(
    base = nome_base,
    camada = layer_name,
    linhas = qtd_linhas,
    colunas = qtd_colunas,
    schema = colunas_info
  )
}

# Gerador do Data Catalog
gerar_catalogo <- function(diretorio_base, layer_name) {
  arquivos <- list.files(diretorio_base, full.names = TRUE)
  
  # Remover arquivos inúteis ou metadados da listagem
  datasets_paths <- arquivos[!str_detect(arquivos, "metadata\\.json|README\\.md")]
  
  metadados_lista <- map(datasets_paths, ~extrair_metadados(.x, layer_name)) %>% 
    compact()
  
  if (length(metadados_lista) == 0) {
    message("Nenhuma base encontrada em ", diretorio_base)
    return(invisible(NULL))
  }
  
  # 1. Salvar JSON
  json_data <- toJSON(metadados_lista, pretty = TRUE, auto_unbox = TRUE)
  write(json_data, file.path(diretorio_base, "metadata.json"))
  
  # 2. Gerar README.md (Dicionário Humano)
  md_content <- c(
    paste0("# Dicionário de Dados: Camada ", toupper(layer_name)),
    paste0("> Gerado automaticamente em: ", Sys.time()),
    "",
    "Este diretório contém os seguintes datasets analisados:",
    ""
  )
  
  for (meta in metadados_lista) {
    md_content <- c(md_content, 
                    paste0("## Base: `", meta$base, "`"),
                    paste0("- **Total de Linhas:** ", format(meta$linhas, big.mark = ".", scientific = FALSE)),
                    paste0("- **Total de Colunas:** ", meta$colunas),
                    "",
                    "### Esquema de Colunas",
                    "| Nome da Coluna | Tipo de Dado |",
                    "| -------------- | ------------ |")
    
    for (col in meta$schema) {
      md_content <- c(md_content, paste0("| `", col$coluna, "` | ", col$tipo, " |"))
    }
    md_content <- c(md_content, "", "---", "")
  }
  
  writeLines(md_content, file.path(diretorio_base, "README.md"))
  
  message("✅ Catálogo gerado com sucesso em: ", diretorio_base)
}

# Execução
message("Gerando Catálogo para a Camada PROCESSED (Silver) - Parquet...")
gerar_catalogo("tse/data/02_silver/parquet", "processed_parquet")

message("Gerando Catálogo para a Camada PROCESSED (Silver) - CSV...")
gerar_catalogo("tse/data/02_silver/csv", "processed_csv")

message("Gerando Catálogo para a Camada GOLD - Parquet...")
gerar_catalogo("tse/data/03_gold/parquet", "gold_parquet")

message("Gerando Catálogo para a Camada GOLD - CSV...")
gerar_catalogo("tse/data/03_gold/csv", "gold_csv")
