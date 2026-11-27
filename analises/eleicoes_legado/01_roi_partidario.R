# ==============================================================================
# ANALYTICS 01: ROI PARTIDÁRIO — TOP 10 PARTIDOS (PREFEITOS 2024 - MG & SP)
# ==============================================================================

if (file.exists("src/config.R")) {
  source("src/config.R")
} else {
  source("../../src/config.R")
}
source("analises/eleicoes/_helpers_vis.R")

datamart <- read_parquet("dados/ouro/datamart_candidatos_2024.parquet")

roi_partidos <- datamart %>%
  filter(cd_cargo == 11L) %>%
  group_by(sg_partido) %>%
  summarise(
    total_candidatos = n(),
    total_eleitos = sum(is_eleito, na.rm = TRUE),
    taxa_sucesso = (total_eleitos / total_candidatos) * 100,
    total_gasto_partido = sum(total_gasto, na.rm = TRUE),
    total_votos_partido = sum(total_votos, na.rm = TRUE),
    custo_medio_voto = ifelse(total_votos_partido > 0, total_gasto_partido / total_votos_partido, NA_real_),
    pct_fundo_publico_medio = mean(pct_fundo_publico, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(custo_medio_voto), custo_medio_voto > 0) %>%
  slice_max(total_eleitos, n = 10, with_ties = FALSE)

g1 <- ggplot(roi_partidos, aes(
  x = custo_medio_voto, y = taxa_sucesso,
  size = total_eleitos, color = pct_fundo_publico_medio,
  text = paste(
    "Partido:", sg_partido,
    "<br>Prefeitos Eleitos:", total_eleitos, "de", total_candidatos,
    "<br>Taxa de Sucesso:", round(taxa_sucesso, 1), "%",
    "<br>Custo Médio/Voto: R$", round(custo_medio_voto, 2),
    "<br>% Fundo Público:", round(pct_fundo_publico_medio, 1), "%"
  )
)) +
  geom_point(alpha = 0.9) +
  geom_text(aes(label = sg_partido), size = 3.5, vjust = -1.4, color = "#0f172a", fontface = "bold") +
  scale_x_continuous(labels = dollar_format(prefix = "R$ ")) +
  scale_size_continuous(range = c(5, 13)) +
  scale_color_viridis_c(option = "viridis", direction = -1) +
  geom_hline(yintercept = median(roi_partidos$taxa_sucesso), linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = median(roi_partidos$custo_medio_voto), linetype = "dashed", color = "gray50") +
  labs(
    title = "ROI Partidário — Top 10 Partidos com Mais Prefeitos Eleitos (2024)",
    subtitle = "Taxa de Sucesso (%) vs. Custo Médio por Voto (R$) em MG e SP",
    x = "Custo Médio por Voto (R$)",
    y = "Taxa de Sucesso (% de Prefeitos Eleitos)",
    color = "% Fundo Público", size = "Prefeitos Eleitos"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g1, "01_roi_partidario.html")
