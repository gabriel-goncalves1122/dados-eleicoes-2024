# ==============================================================================
# ANALYTICS 08: REPRESENTATIVIDADE RACIAL (CENSO 2022 vs. CANDIDATOS vs. ELEITOS)
# ==============================================================================
# Responde: Como a pirâmide racial da população (Branca, Parda, Preta, Indígena)
# se reflete nas candidaturas e nos eleitos de MG e SP?

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

df_mun <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet")

resumo_raca <- df_mun %>%
  group_by(sg_uf) %>%
  summarise(
    Censo_Branca = weighted.mean(pct_branca_censo, populacao_2022, na.rm = TRUE),
    Cand_Branca = weighted.mean(pct_cand_branca, total_candidatos, na.rm = TRUE),
    Eleitos_Branca = weighted.mean(pct_eleitos_branca, total_eleitos, na.rm = TRUE),
    Censo_Parda = weighted.mean(pct_parda_censo, populacao_2022, na.rm = TRUE),
    Cand_Parda = weighted.mean(pct_cand_parda, total_candidatos, na.rm = TRUE),
    Eleitos_Parda = weighted.mean(pct_eleitos_parda, total_eleitos, na.rm = TRUE),
    Censo_Preta = weighted.mean(pct_preta_censo, populacao_2022, na.rm = TRUE),
    Cand_Preta = weighted.mean(pct_cand_preta, total_candidatos, na.rm = TRUE),
    Eleitos_Preta = weighted.mean(pct_eleitos_preta, total_eleitos, na.rm = TRUE),
    Censo_Indigena = weighted.mean(pct_indigena_censo, populacao_2022, na.rm = TRUE),
    Cand_Indigena = weighted.mean(pct_cand_indigena, total_candidatos, na.rm = TRUE),
    Eleitos_Indigena = weighted.mean(pct_eleitos_indigena, total_eleitos, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-sg_uf, names_to = "metrica", values_to = "percentual") %>%
  separate(metrica, into = c("estagio", "raca"), sep = "_") %>%
  mutate(
    estagio = factor(
      recode(estagio, "Censo" = "1. População (Censo 2022)", "Cand" = "2. Candidatos (2024)", "Eleitos" = "3. Eleitos (2024)"),
      levels = c("1. População (Censo 2022)", "2. Candidatos (2024)", "3. Eleitos (2024)")
    ),
    raca = factor(recode(raca, "Indigena" = "Indígena"), levels = c("Branca", "Parda", "Preta", "Indígena"))
  )

g8 <- ggplot(resumo_raca, aes(
  x = raca, y = percentual, fill = estagio,
  text = paste("UF:", sg_uf, "<br>Cor/Raça:", raca, "<br>Estágio:", estagio, "<br>Proporção:", round(percentual, 1), "%")
)) +
  geom_col(position = "dodge") +
  facet_wrap(~sg_uf) +
  scale_fill_manual(values = c(
    "1. População (Censo 2022)" = "#64748b",
    "2. Candidatos (2024)" = "#3b82f6",
    "3. Eleitos (2024)" = "#10b981"
  )) +
  labs(
    title = "Funil de Representatividade Racial: Censo 2022 vs. Candidatos vs. Eleitos (2024)",
    subtitle = "Média ponderada pela população / volume eleitoral em MG e SP",
    x = "Cor / Raça", y = "Proporção (%)", fill = "Estágio"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g8, "08_representatividade_raca_censo_urnas.html")
