# ==============================================================================
# ANALYTICS 09: EVOLUÇÃO DA REPRESENTATIVIDADE POR PORTE DO MUNICÍPIO (2024)
# ==============================================================================
# Mostra como a % de mulheres eleitas e de negros/indígenas eleitos evolui
# desde pequenos municípios (<20k) até as metrópoles (>500k).

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

df_mun <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet") %>%
  mutate(
    porte_municipio = factor(porte_municipio, levels = c(
      "Pequeno Porte I (<20k)", "Pequeno Porte II (20k-50k)",
      "Médio Porte (50k-100k)", "Grande Porte (100k-500k)", "Metrópole (>500k)"
    ))
  )

evolucao_porte <- df_mun %>%
  group_by(porte_municipio) %>%
  summarise(
    qtd_municipios = n(),
    `Mulheres Eleitas (%)` = mean(pct_eleitos_mulheres, na.rm = TRUE),
    `Mulheres no Censo (%)` = mean(pct_mulheres_censo, na.rm = TRUE),
    `Pretos/Pardos/Indíg. Eleitos (%)` = mean(pct_eleitos_negros_indigenas, na.rm = TRUE),
    `Pretos/Pardos/Indíg. no Censo (%)` = mean(pct_negros_indigenas_censo, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = -c(porte_municipio, qtd_municipios),
    names_to = "indicador", values_to = "pct"
  )

g9 <- ggplot(evolucao_porte, aes(
  x = porte_municipio, y = pct, color = indicador, group = indicador,
  text = paste(
    "Porte:", porte_municipio, " (", qtd_municipios, " municípios)",
    "<br>Indicador:", indicador,
    "<br>Média:", round(pct, 1), "%"
  )
)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 3.5) +
  scale_y_continuous(limits = c(10, 60), labels = function(x) paste0(x, "%")) +
  scale_color_manual(values = c(
    "Mulheres no Censo (%)" = "#94a3b8",
    "Mulheres Eleitas (%)" = "#e11d48",
    "Pretos/Pardos/Indíg. no Censo (%)" = "#64748b",
    "Pretos/Pardos/Indíg. Eleitos (%)" = "#2563eb"
  )) +
  labs(
    title = "Representatividade por Porte do Município: Censo 2022 vs. Eleitos 2024",
    subtitle = "Comparativo da média de eleitos frente ao patamar demográfico em cada faixa populacional",
    x = "Porte Populacional do Município", y = "Proporção Média (%)", color = NULL
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g9, "09_gap_representatividade_porte_uf.html")
