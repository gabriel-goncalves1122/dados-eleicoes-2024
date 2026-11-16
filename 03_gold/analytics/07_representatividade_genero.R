# ==============================================================================
# ANALYTICS 07: REPRESENTATIVIDADE DE GÊNERO (CENSO 2022 vs. ELEIÇÕES 2024)
# ==============================================================================
# Responde: A proporção de mulheres candidatas e eleitas acompanha o peso real
# das mulheres na população dos 1.498 municípios de MG e SP?

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

df_mun <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet") %>%
  filter(!is.na(pct_mulheres_censo), !is.na(pct_eleitos_mulheres))

g7 <- ggplot(df_mun, aes(
  x = pct_mulheres_censo, y = pct_eleitos_mulheres,
  color = sg_uf, size = populacao_2022,
  text = paste(
    "Município:", nm_municipio, "-", sg_uf,
    "<br>População (2022):", format(populacao_2022, big.mark = "."),
    "<br>% Mulheres (Censo):", round(pct_mulheres_censo, 1), "%",
    "<br>% Candidatas (2024):", round(pct_cand_mulheres, 1), "%",
    "<br>% Eleitas (2024):", round(pct_eleitos_mulheres, 1), "%",
    "<br>Gap (Eleitas - Censo):", round(gap_eleitos_mulheres, 1), "pp"
  )
)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "#334155") +
  geom_hline(yintercept = 30, linetype = "dotted", color = "#e11d48") +
  geom_point(alpha = 0.55) +
  scale_color_manual(values = c("MG" = "#2563eb", "SP" = "#f59e0b")) +
  labs(
    title = "Representatividade Feminina: % Mulheres no Censo 2022 vs. % Eleitas em 2024",
    subtitle = "Linha tracejada = paridade demográfica (y = x) | Linha pontilhada = cota mínima de 30% de candidaturas",
    x = "% de Mulheres na População (Censo 2022)",
    y = "% de Mulheres Eleitas (Prefeitas + Vereadoras)",
    color = "Estado (UF)", size = "População 2022"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g7, "07_representatividade_genero_censo_urnas.html")
