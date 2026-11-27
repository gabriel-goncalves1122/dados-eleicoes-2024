# ==============================================================================
# GOVERNANÇA: GERADOR DE DATA CATALOG E METADADOS (100% PARQUET)
# ==============================================================================

if (file.exists("src/config.R")) {
  source("src/config.R")
} else if (file.exists("../../src/config.R")) {
  source("../../src/config.R")
}

library(tidyverse)
library(arrow)
library(jsonlite)
library(fs)

extrair_metadados <- function(path_to_parquet, layer_name) {
  ds <- tryCatch(open_dataset(path_to_parquet), error = function(e) NULL)
  if (is.null(ds)) return(NULL)
  esquema <- ds$schema
  colunas_info <- lapply(names(esquema), function(col_name) {
    list(coluna = col_name, tipo = esquema$GetFieldByName(col_name)$type$ToString())
  })
  list(
    base = basename(path_to_parquet),
    caminho = path_to_parquet,
    camada = layer_name,
    linhas = tryCatch(nrow(ds), error = function(e) NA_integer_),
    colunas = ncol(ds),
    schema = colunas_info
  )
}

gerar_catalogo <- function(diretorio_dados, layer_name, subdir_saida, prefix = NULL) {
  if (!dir_exists(diretorio_dados)) return(invisible(NULL))
  arquivos <- dir_ls(diretorio_dados, glob = "*.parquet")
  if (!is.null(prefix)) {
    arquivos <- arquivos[str_starts(basename(arquivos), prefix)]
  }
  metadados_lista <- map(arquivos, ~extrair_metadados(.x, layer_name)) %>% compact()
  if (length(metadados_lista) == 0) return(invisible(NULL))

  out_dir <- file.path(DOCS_CATALOGO, subdir_saida)
  dir_create(out_dir)

  write(toJSON(metadados_lista, pretty = TRUE, auto_unbox = TRUE), file.path(out_dir, "metadata.json"))

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
  writeLines(md_content, file.path(out_dir, "README.md"))
  message("✔ Catálogo Parquet gerado em: ", out_dir)
}

gerar_catalogo(DADOS_PRATA, "prata_dimensoes", "prata_dimensoes", prefix = "dim_")
gerar_catalogo(DADOS_PRATA, "prata_fatos", "prata_fatos", prefix = "fato_")
gerar_catalogo(DADOS_OURO, "ouro_datamarts", "ouro")
