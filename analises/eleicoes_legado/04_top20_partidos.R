# ==============================================================================
# ANALYTICS 04: TOP 20 PARTIDOS POR VOLUME DE RECEITAS (PÚBLICO VS PRIVADO)
# ==============================================================================

if (file.exists("src/config.R")) {
  source("src/config.R")
} else {
  source("../../src/config.R")
}
source("analises/eleicoes/_helpers_vis.R")

datamart <- read_parquet("dados/ouro/datamart_candidatos_2024.parquet")

top20 <- datamart %>%
  group_by(sg_partido) %>%
  summarise(
    fundo_publico = sum(total_fundo_publico, na.rm = TRUE),
    recursos_privados = pmax(sum(total_arrecadado, na.rm = TRUE) - fundo_publico, 0),
    total = fundo_publico + recursos_privados,
    .groups = "drop"
  ) %>%
  slice_max(total, n = 20) %>%
  pivot_longer(cols = c(fundo_publico, recursos_privados), names_to = "origem", values_to = "valor") %>%
  mutate(
    origem = recode(origem, "fundo_publico" = "Fundo Público", "recursos_privados" = "Recursos Privados/Outros"),
    sg_partido = fct_reorder(sg_partido, total)
  )

g4 <- ggplot(top20, aes(
  x = valor / 1e6, y = sg_partido, fill = origem,
  text = paste("Partido:", sg_partido, "<br>Origem:", origem, "<br>Valor: R$", round(valor / 1e6, 2), "Mi")
)) +
  geom_col() +
  scale_fill_manual(values = c("Fundo Público" = "#2563eb", "Recursos Privados/Outros" = "#f59e0b")) +
  labs(
    title = "Top 20 Partidos por Arrecadação Total (Eleições 2024 - MG & SP)",
    subtitle = "Composição entre Fundo Público e Recursos Privados (Milhões R$)",
    x = "Volume Financeiro (Milhões R$)", y = NULL, fill = "Origem"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g4, "04_top20_partidos.html")
