# ==============================================================================
# ANALYTICS 05: TOP 25 CAMPANHAS DE PREFEITO DE MAIOR ORÇAMENTO (2024)
# ==============================================================================

if (file.exists("src/config.R")) {
  source("src/config.R")
} else {
  source("../../src/config.R")
}
source("analises/eleicoes/_helpers_vis.R")

datamart <- read_parquet("dados/ouro/datamart_candidatos_2024.parquet")

top_gastos <- datamart %>%
  filter(cd_cargo == 11L, total_gasto > 0) %>%
  slice_max(total_gasto, n = 25) %>%
  mutate(
    label_cand = paste0(nm_urna_candidato, " (", sg_partido, " - ", nm_municipio, "/", sg_uf, ")"),
    label_cand = fct_reorder(label_cand, total_gasto),
    resultado = ifelse(is_eleito, "Eleito", "Não Eleito")
  )

g5 <- ggplot(top_gastos, aes(
  x = total_gasto / 1e6, y = label_cand, fill = resultado,
  text = paste(
    "Candidato:", nm_urna_candidato,
    "<br>Município:", nm_municipio, "-", sg_uf,
    "<br>Gasto: R$", round(total_gasto / 1e6, 2), "Mi",
    "<br>Votos:", format(total_votos, big.mark = "."),
    "<br>Status:", status_eleicao
  )
)) +
  geom_col() +
  scale_fill_manual(values = c("Eleito" = "#10b981", "Não Eleito" = "#ef4444")) +
  labs(
    title = "Top 25 Maiores Orçamentos para Prefeito (2024 - MG & SP)",
    x = "Gasto Contratado (Milhões R$)", y = NULL, fill = "Resultado"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g5, "05_top_campanhas_milionarias.html")
