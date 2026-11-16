# ==============================================================================
# ANALYTICS 10: ECONOMIA POLÍTICA — PESO DO SETOR PÚBLICO VS. GASTO E FUNDO
# ==============================================================================
# Responde: Municípios mais dependentes da Administração Pública (% do VAB)
# dependem mais do Fundo Eleitoral Público ou gastam mais por habitante?

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

df_mun <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet") %>%
  filter(!is.na(pct_adm_publica_vab_2021), !is.na(gasto_campanha_per_capita), gasto_campanha_per_capita > 0)

g10 <- ggplot(df_mun, aes(
  x = pct_adm_publica_vab_2021, y = gasto_campanha_per_capita,
  color = pct_fundo_publico_municipio, size = populacao_2022,
  text = paste(
    "Município:", nm_municipio, "-", sg_uf,
    "<br>% Adm. Pública no VAB:", round(pct_adm_publica_vab_2021, 1), "%",
    "<br>Gasto/Habitante: R$", round(gasto_campanha_per_capita, 2),
    "<br>% Fundo Público:", round(pct_fundo_publico_municipio, 1), "%",
    "<br>PIB per Capita: R$", format(round(pib_per_capita_reais, 0), big.mark = ".")
  )
)) +
  geom_point(alpha = 0.6) +
  geom_smooth(aes(group = sg_uf), method = "lm", se = FALSE, color = "#0f172a", linetype = "dashed") +
  facet_wrap(~sg_uf) +
  scale_y_log10(labels = dollar_format(prefix = "R$ ")) +
  scale_color_viridis_c(option = "plasma") +
  labs(
    title = "Economia Política: Peso do Setor Público vs. Gasto Eleitoral per Capita (2024)",
    subtitle = "Cor indica % de dependência do Fundo Público | Linha tracejada = tendência linear (escala log)",
    x = "Participação da Administração Pública no VAB Municipal (% - IBGE)",
    y = "Gasto Total de Campanha por Habitante (R$ - Escala Log)",
    color = "% Fundo Público", size = "População"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g10, "10_economia_publica_vs_campanhas.html")
