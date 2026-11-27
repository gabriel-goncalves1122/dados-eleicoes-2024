# ==============================================================================
# HELPER ANALÍTICO COMPARTILHADO (CAMINHO BASE, TABELAS CSV E GRÁFICOS PNG)
# ==============================================================================

if (file.exists("src/config.R")) {
  source("src/config.R")
} else if (file.exists("../../src/config.R")) {
  source("../../src/config.R")
}

library(tidyverse)
library(arrow)
library(scales)
library(fs)

if (file.exists("analises/_tema_apresentacao.R")) {
  source("analises/_tema_apresentacao.R")
} else {
  source("../_tema_apresentacao.R")
}

OUT_FIGURAS <- path(ANALISES_ELEI_OUT, "figuras")
OUT_TABELAS <- path(ANALISES_ELEI_OUT, "tabelas")
dir_create(OUT_FIGURAS)
dir_create(OUT_TABELAS)

ler_ouro <- function(arquivo) {
  caminho <- path(DADOS_OURO, arquivo)
  if (!file_exists(caminho)) {
    stop("Datamart Ouro não encontrado: ", caminho, ". Execute Rscript src/pipeline.R modelagem.")
  }
  read_parquet(caminho)
}

salvar_grafico <- function(plot_obj, nome_arquivo, width = 11, height = 6.5, dpi = 180) {
  destino <- path(OUT_FIGURAS, nome_arquivo)
  ggsave(destino, plot = plot_obj, width = width, height = height, dpi = dpi, bg = "white")
  message("✔ Gráfico salvo: ", destino)
  invisible(destino)
}

salvar_tabela <- function(df, nome_arquivo) {
  destino <- path(OUT_TABELAS, nome_arquivo)
  write_csv(df, destino)
  message("✔ Tabela salva: ", destino, " (", nrow(df), " linhas)")
  invisible(destino)
}
