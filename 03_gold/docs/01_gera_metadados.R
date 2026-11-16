# ==============================================================================
# GOVERNANÇA: GERADOR DE DATA CATALOG E METADADOS (100% PARQUET)
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(jsonlite)
library(fs)

extrair_metadados <- function(path_to_dataset, layer_name) {
  ds <- tryCatch(open_dataset(path_to_dataset), error = function(e) NULL)
  if (is.null(ds)) return(NULL)
  esquema <- ds$schema
  colunas_info <- lapply(names(esquema), function(col_name) {
    list(coluna = col_name, tipo = esquema$GetFieldByName(col_name)$type$ToString())
  })
  list(
    base = basename(path_to_dataset),
    camada = layer_name,
    linhas = tryCatch(nrow(ds), error = function(e) NA_integer_),
    colunas = ncol(ds),
    schema = colunas_info
  )
}

gerar_catalogo <- function(diretorio_base, layer_name) {
  if (!dir_exists(diretorio_base)) return(invisible(NULL))
  arquivos <- dir_ls(diretorio_base, glob = "*.parquet")
  metadados_lista <- map(arquivos, ~extrair_metadados(.x, layer_name)) %>% compact()
  if (length(metadados_lista) == 0) return(invisible(NULL))

  write(toJSON(metadados_lista, pretty = TRUE, auto_unbox = TRUE), file.path(diretorio_base, "metadata.json"))

  md_content <- c(
    paste0("# Dicionário de Dados: ", toupper(layer_name)),
    paste0("> Gerado em: ", Sys.time()),
    ""
  )
  for (meta in metadados_lista) {
    linhas_str <- ifelse(is.na(meta$linhas), "N/A", format(meta$linhas, big.mark = ".", scientific = FALSE))
    md_content <- c(
      md_content,
      paste0("## Base: `", meta$base, "`"),
      paste0("- **Linhas:** ", linhas_str, " | **Colunas:** ", meta$colunas),
      "",
      "| Coluna | Tipo |",
      "| ------ | ---- |"
    )
    for (col in meta$schema) {
      md_content <- c(md_content, paste0("| `", col$coluna, "` | ", col$tipo, " |"))
    }
    md_content <- c(md_content, "", "---", "")
  }
  writeLines(md_content, file.path(diretorio_base, "README.md"))
  message("✔ Catálogo Parquet gerado em: ", diretorio_base)
}

gerar_catalogo("02_silver/data/tse", "silver_tse_parquet")
gerar_catalogo("02_silver/data/ibge", "silver_ibge_parquet")
gerar_catalogo("03_gold/data", "gold_datamarts_parquet")
