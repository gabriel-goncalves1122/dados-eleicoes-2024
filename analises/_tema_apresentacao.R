# ==============================================================================
# TEMA VISUAL E FORMATADORES PT-BR COMPARTILHADOS (BLUE PROFESSIONAL)
# ==============================================================================

PALETA <- list(
  azul        = "#1e2bfa",
  azul_medio  = "#3b82f6",
  azul_suave  = "#93c5fd",
  esmeralda   = "#059669",
  ambar       = "#d97706",
  carmim      = "#dc2626",
  grafite     = "#1e293b",
  slate       = "#64748b",
  slate_claro = "#94a3b8",
  grid        = "#e2e8f0"
)

fmt_num_br <- function(x, dec = 1) {
  formatC(x, format = "f", digits = dec, big.mark = ".", decimal.mark = ",")
}

fmt_int_br <- function(x) {
  formatC(round(x), format = "f", digits = 0, big.mark = ".", decimal.mark = ",")
}

fmt_pct_br <- function(x, dec = 1) {
  paste0(fmt_num_br(x, dec = dec), "%")
}

fmt_reais_curto <- function(x) {
  vapply(x, function(v) {
    if (is.na(v)) return(NA_character_)
    av <- abs(v)
    sinal <- if (v < 0) "-" else ""
    if (av >= 1e9) return(paste0(sinal, "R$ ", fmt_num_br(av / 1e9, 2), " bi"))
    if (av >= 1e6) return(paste0(sinal, "R$ ", fmt_num_br(av / 1e6, 1), "M"))
    if (av >= 1e3) return(paste0(sinal, "R$ ", fmt_num_br(av / 1e3, 1), " mil"))
    paste0(sinal, "R$ ", fmt_num_br(av, 2))
  }, character(1))
}

tema_slide <- function(base_size = 13) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = PALETA$grid, linewidth = 0.45),
      plot.title       = element_text(face = "bold", size = base_size + 2.5, color = "#0f172a", margin = margin(b = 4)),
      plot.subtitle    = element_text(size = base_size - 1.5, color = "#475569", margin = margin(b = 12)),
      plot.title.position = "plot",
      axis.title       = element_text(size = base_size - 1, face = "bold", color = "#334155"),
      axis.text        = element_text(size = base_size - 1.5, color = "#334155"),
      strip.text       = element_text(face = "bold", size = base_size - 0.5, color = "#0f172a"),
      legend.position  = "top",
      legend.justification = "left",
      legend.title     = element_text(face = "bold", size = base_size - 1.5, color = "#334155"),
      legend.text      = element_text(size = base_size - 1.5, color = "#334155"),
      legend.key.size  = unit(0.45, "cm"),
      plot.margin      = margin(14, 18, 12, 14)
    )
}
