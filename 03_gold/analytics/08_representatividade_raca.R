# ==============================================================================
# ANALYTICS 08: REPRESENTATIVIDADE RACIAL — POPULAÇÃO CENSO vs. ELEITOS (2024)
# ==============================================================================
# Comparação direta entre a população de cada raça no Censo 2022 e a proporção
# de políticos efetivamente eleitos em 2024.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

df_mun <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet")

comp_raca <- df_mun %>%
  group_by(sg_uf) %>%
  summarise(
    `População Censo 2022_Branca` = weighted.mean(pct_branca_censo, populacao_2022, na.rm = TRUE),
    `Eleitos em 2024_Branca` = weighted.mean(pct_eleitos_branca, total_eleitos, na.rm = TRUE),
    `População Censo 2022_Parda` = weighted.mean(pct_parda_censo, populacao_2022, na.rm = TRUE),
    `Eleitos em 2024_Parda` = weighted.mean(pct_eleitos_parda, total_eleitos, na.rm = TRUE),
    `População Censo 2022_Preta` = weighted.mean(pct_preta_censo, populacao_2022, na.rm = TRUE),
    `Eleitos em 2024_Preta` = weighted.mean(pct_eleitos_preta, total_eleitos, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-sg_uf, names_to = "chave", values_to = "pct") %>%
  separate(chave, into = c("grupo", "raca"), sep = "_") %>%
  mutate(
    raca = factor(raca, levels = c("Branca", "Parda", "Preta")),
    grupo = factor(grupo, levels = c("População Censo 2022", "Eleitos em 2024"))
  )

g8 <- ggplot(comp_raca, aes(
  x = raca, y = pct, fill = grupo,
  text = paste("Estado:", sg_uf, "<br>Cor/Raça:", raca, "<br>", grupo, ":", round(pct, 1), "%")
)) +
  geom_col(position = position_dodge(width = 0.72), width = 0.65) +
  facet_wrap(~sg_uf) +
  scale_y_continuous(limits = c(0, 80), labels = function(x) paste0(x, "%")) +
  scale_fill_manual(values = c("População Censo 2022" = "#475569", "Eleitos em 2024" = "#0d9488")) +
  labs(
    title = "Representatividade Racial: População (Censo 2022) vs. Eleitos (2024)",
    subtitle = "Sobre-representação de brancos e sub-representação de pardos e pretos em MG e SP",
    x = "Cor / Raça", y = "Participação (%)", fill = NULL
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g8, "08_representatividade_raca_censo_urnas.html")
