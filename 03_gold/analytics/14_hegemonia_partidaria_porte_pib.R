# ==============================================================================
# ANALYTICS 14: HEGEMONIA PARTIDÁRIA POR PORTE E RIQUEZA (PREFEITURAS 2024)
# ==============================================================================
# Responde: Quais partidos governam os municípios mais ricos vs. os mais
# dependentes da Administração Pública e de menor porte em MG e SP?

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

df_mun <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet") %>%
  filter(!is.na(prefeito_eleito_partido), !is.na(pib_per_capita_reais))

top_partidos <- df_mun %>%
  count(prefeito_eleito_partido, sort = TRUE) %>%
  slice_head(n = 12) %>%
  pull(prefeito_eleito_partido)

perfil_partidos <- df_mun %>%
  filter(prefeito_eleito_partido %in% top_partidos) %>%
  group_by(prefeito_eleito_partido) %>%
  summarise(
    qtd_prefeituras = n(),
    pop_governada_mi = sum(populacao_2022, na.rm = TRUE) / 1e6,
    pib_pc_mediano = median(pib_per_capita_reais, na.rm = TRUE),
    adm_pub_mediana = median(pct_adm_publica_vab_2021, na.rm = TRUE),
    pct_pequeno_porte = mean(populacao_2022 < 20000, na.rm = TRUE) * 100,
    .groups = "drop"
  )

g14 <- ggplot(perfil_partidos, aes(
  x = adm_pub_mediana, y = pib_pc_mediano,
  size = pop_governada_mi, color = qtd_prefeituras,
  text = paste(
    "Partido:", prefeito_eleito_partido,
    "<br>Prefeituras Eleitas:", qtd_prefeituras,
    "<br>População Governada:", round(pop_governada_mi, 2), "Mi hab.",
    "<br>PIB per Capita Mediano: R$", format(round(pib_pc_mediano, 0), big.mark = "."),
    "<br>% Adm. Pública Mediana:", round(adm_pub_mediana, 1), "%",
    "<br>% Cidades Pequenas (<20k):", round(pct_pequeno_porte, 1), "%"
  )
)) +
  geom_point(alpha = 0.85) +
  geom_text(aes(label = prefeito_eleito_partido), size = 3.2, vjust = -1.3, color = "black", check_overlap = TRUE) +
  scale_y_continuous(labels = dollar_format(prefix = "R$ ")) +
  scale_color_viridis_c(option = "viridis") +
  labs(
    title = "Hegemonia Partidária nas Prefeituras: Riqueza vs. Dependência Pública (2024)",
    subtitle = "Top 12 partidos em nº de prefeituras (MG & SP) | Tamanho = população governada (milhões)",
    x = "Dependência Mediana da Administração Pública no VAB (% - IBGE)",
    y = "PIB per Capita Mediano dos Municípios Governados (R$)",
    color = "Nº Prefeituras", size = "Pop. Governada (Mi)"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g14, "14_hegemonia_partidaria_porte_pib.html")
