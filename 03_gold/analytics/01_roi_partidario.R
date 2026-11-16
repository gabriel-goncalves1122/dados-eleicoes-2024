# ==============================================================================
# ANALYTICS 01: ROI PARTIDÁRIO PARA PREFEITOS (ELEIÇÕES 2024 - MG & SP)
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

datamart <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet")

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
  filter(total_candidatos >= 10, !is.na(custo_medio_voto), custo_medio_voto > 0)

g1 <- ggplot(roi_partidos, aes(
  x = custo_medio_voto, y = taxa_sucesso,
  size = total_eleitos, color = pct_fundo_publico_medio,
  text = paste(
    "Partido:", sg_partido,
    "<br>Custo Médio/Voto: R$", round(custo_medio_voto, 2),
    "<br>Prefeitos Eleitos:", total_eleitos,
    "<br>Taxa de Sucesso:", round(taxa_sucesso, 1), "%",
    "<br>% Fundo Público:", round(pct_fundo_publico_medio, 1), "%"
  )
)) +
  geom_point(alpha = 0.85) +
  geom_text(aes(label = sg_partido), size = 3, vjust = -1.3, color = "black", check_overlap = TRUE) +
  scale_x_log10(labels = dollar_format(prefix = "R$ ")) +
  scale_color_viridis_c(option = "magma", direction = -1) +
  geom_hline(yintercept = median(roi_partidos$taxa_sucesso), linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = median(roi_partidos$custo_medio_voto), linetype = "dashed", color = "gray50") +
  labs(
    title = "ROI Partidário - Eleições Municipais 2024 (MG & SP)",
    subtitle = "Disputa para Prefeito: Taxa de Sucesso vs. Custo Médio por Voto",
    x = "Custo Médio por Voto (R$ - Escala Log)",
    y = "Taxa de Sucesso (% de Eleitos)",
    color = "% Fundo Público", size = "Qtd. Eleitos"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g1, "01_roi_partidario.html")
