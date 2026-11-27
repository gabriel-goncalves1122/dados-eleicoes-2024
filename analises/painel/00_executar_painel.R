# ==============================================================================
# EXECUTOR DO PAINEL EXECUTIVO (K1,K3,K4 | P1,P2,P4 | B1..B18 | T1..T6 | R1,R2)
# ==============================================================================

scripts <- sort(list.files("analises/painel", pattern = "^0[1-5]_.*\\.R$", full.names = TRUE))
if (length(scripts) == 0) {
  scripts <- sort(list.files(".", pattern = "^0[1-5]_.*\\.R$", full.names = TRUE))
}

inicio <- Sys.time()
for (s in scripts) {
  message("\n-----------------------------------------------------------------")
  message("▶ Rodando: ", s)
  source(s, local = new.env(parent = globalenv()))
}
duracao <- round(as.numeric(difftime(Sys.time(), inicio, units = "secs")), 1)
message("\n🏁 PAINEL CONCLUÍDO em ", duracao, "s.")
