# ==============================================================================
# EXECUTOR MESTRE: TODAS AS 10 ANÁLISES NACIONAIS (BRASIL 2024)
# ==============================================================================

scripts <- sort(list.files("analises/eleicoes", pattern = "^(0[1-9]|10)_.*\\.R$", full.names = TRUE))
if (length(scripts) == 0) {
  scripts <- sort(list.files(".", pattern = "^(0[1-9]|10)_.*\\.R$", full.names = TRUE))
}

inicio <- Sys.time()
for (s in scripts) {
  message("\n-----------------------------------------------------------------")
  message("▶ Rodando: ", s)
  source(s, local = new.env(parent = globalenv()))
}
duracao <- round(as.numeric(difftime(Sys.time(), inicio, units = "secs")), 1)
message("\n🏁 TODAS AS ", length(scripts), " ANÁLISES CONCLUÍDAS em ", duracao, "s.")
