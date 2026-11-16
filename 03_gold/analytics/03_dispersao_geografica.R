# ==============================================================================
# ANALYTICS 03: TOP 50 MAIORES PATRIMÔNIOS VS. VOTOS PARA PREFEITO (2024)
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

datamart <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet")

top50_patrimonio <- datamart %>%
  filter(cd_cargo == 11L, total_patrimonio_declarado > 0, total_votos > 0) %>%
  slice_max(total_patrimonio_declarado, n = 50, with_ties = FALSE) %>%
  mutate(resultado = ifelse(is_eleito, "Eleito", "Não Eleito"))

g3 <- ggplot(top50_patrimonio, aes(
  x = total_patrimonio_declarado / 1e6, y = total_votos, color = resultado,
  text = paste(
    "Candidato:", nm_urna_candidato, " (", sg_partido, ")",
    "<br>Município:", nm_municipio, "-", sg_uf,
    "<br>Patrimônio: R$", round(total_patrimonio_declarado / 1e6, 2), "Mi",
    "<br>Votos:", format(total_votos, big.mark = "."),
    "<br>Resultado:", resultado
  )
)) +
  geom_point(alpha = 0.88, size = 4) +
  scale_x_log10(labels = function(x) paste0("R$ ", x, " Mi")) +
  scale_y_log10(labels = label_number(big.mark = ".")) +
  scale_color_manual(values = c("Eleito" = "#2563eb", "Não Eleito" = "#f97316")) +
  labs(
    title = "Top 50 Candidatos a Prefeito mais Ricos: Patrimônio vs. Votos (2024)",
    subtitle = "Comparativo entre Eleitos (Azul) e Não Eleitos (Laranja) em MG e SP",
    x = "Patrimônio Declarado (Milhões R$ - Escala Log)",
    y = "Votos Obtidos (Escala Log)",
    color = "Resultado"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g3, "03_patrimonio_vs_votos.html")
