# ==============================================================================
# HELPER DO PAINEL EXECUTIVO (KPIS, PIZZAS, BARRAS, SÉRIES E RANKINGS)
# ==============================================================================

if (file.exists("src/config.R")) {
  source("src/config.R")
} else if (file.exists("../../src/config.R")) {
  source("../../src/config.R")
}

library(tidyverse)
library(arrow)
library(scales)
library(DBI)
library(duckdb)
library(fs)

if (file.exists("analises/_tema_apresentacao.R")) {
  source("analises/_tema_apresentacao.R")
} else {
  source("../_tema_apresentacao.R")
}

PAINEL_OUT <- "analises/painel/output"
PAINEL_FIG <- path(PAINEL_OUT, "figuras")
PAINEL_TAB <- path(PAINEL_OUT, "tabelas")
dir_create(PAINEL_FIG)
dir_create(PAINEL_TAB)

ler_ouro <- function(arquivo) {
  read_parquet(path(DADOS_OURO, arquivo))
}

prata_sql <- function(arquivo) {
  normalizePath(path(DADOS_PRATA, arquivo), winslash = "/")
}

salvar_fig <- function(p, nome, width = 10, height = 6, dpi = 180) {
  dest <- path(PAINEL_FIG, nome)
  ggsave(dest, plot = p, width = width, height = height, dpi = dpi, bg = "white")
  message("✔ Gráfico salvo: ", dest)
  invisible(dest)
}

salvar_tab <- function(df, nome) {
  dest <- path(PAINEL_TAB, nome)
  write_csv(df, dest)
  message("✔ Tabela salva: ", dest, " (", nrow(df), " linhas)")
  invisible(dest)
}

fazer_pizza <- function(df_fatias, titulo, subtitulo = NULL, cores = NULL) {
  df_plot <- df_fatias %>%
    arrange(desc(valor)) %>%
    mutate(
      categoria = factor(categoria, levels = categoria),
      pct = 100 * valor / sum(valor),
      rotulo = paste0(fmt_pct_br(pct, 1), "\n(", fmt_reais_curto(valor), ")")
    )
  p <- ggplot(df_plot, aes(x = 2, y = pct, fill = categoria)) +
    geom_col(color = "white", linewidth = 1.2, width = 1) +
    coord_polar(theta = "y", start = 0, direction = -1) +
    xlim(0.55, 2.55) +
    geom_text(
      aes(label = ifelse(pct >= 8, rotulo, fmt_pct_br(pct, 1))),
      position = position_stack(vjust = 0.5),
      size = 4.2, fontface = "bold", color = "white"
    ) +
    labs(title = titulo, subtitle = subtitulo, fill = NULL) +
    tema_slide(base_size = 13) +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank()
    )
  if (!is.null(cores)) p <- p + scale_fill_manual(values = cores)
  p
}
