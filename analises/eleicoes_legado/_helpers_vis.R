# ==============================================================================
# HELPER DE VISUALIZAÇÃO: TEMA PADRÃO E EXPORTAÇÃO HTML INTERATIVA
# ==============================================================================

library(tidyverse)
library(arrow)
library(plotly)
library(scales)

salvar_e_exibir_plotly <- function(grafico, nome_arquivo_html, tooltip = "text") {
  if (inherits(grafico, "plotly")) {
    p <- grafico
  } else {
    p <- ggplotly(grafico, tooltip = tooltip)
  }

  pasta_out <- if (exists("ANALISES_ELEI_OUT")) ANALISES_ELEI_OUT else "analises/eleicoes/output"
  if (!dir.exists(pasta_out)) dir.create(pasta_out, recursive = TRUE)
  destino <- file.path(pasta_out, nome_arquivo_html)

  if (requireNamespace("htmlwidgets", quietly = TRUE)) {
    usar_self <- requireNamespace("rmarkdown", quietly = TRUE) && rmarkdown::pandoc_available()
    htmlwidgets::saveWidget(
      p,
      file = normalizePath(destino, mustWork = FALSE),
      selfcontained = usar_self,
      libdir = "lib"
    )
    message("💾 Gráfico interativo exportado em: ", destino)
  }

  print(p)
  invisible(p)
}
