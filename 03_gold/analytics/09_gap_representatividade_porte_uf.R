# ==============================================================================
# ANALYTICS 09: GAP DE REPRESENTATIVIDADE POR PORTE DO MUNICÍPIO E ESTADO
# ==============================================================================
# Responde: O déficit de representatividade (Eleitos % - Censo %) de mulheres
# e pessoas negras/indígenas muda conforme o porte populacional do município?

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
  ) %>%
  select(sg_uf, nm_municipio, porte_municipio, gap_eleitos_mulheres, gap_eleitos_negros_indigenas) %>%
  pivot_longer(
    cols = c(gap_eleitos_mulheres, gap_eleitos_negros_indigenas),
    names_to = "dimensao", values_to = "gap_pp"
  ) %>%
  mutate(
    dimensao = recode(
      dimensao,
      "gap_eleitos_mulheres" = "Mulheres (Eleitas % - Censo %)",
      "gap_eleitos_negros_indigenas" = "Pretos/Pardos/Indígenas (Eleitos % - Censo %)"
    )
  )

g9 <- ggplot(df_mun, aes(x = porte_municipio, y = gap_pp, fill = sg_uf)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#0f172a") +
  geom_boxplot(alpha = 0.75, outlier.alpha = 0.25) +
  facet_wrap(~dimensao, ncol = 1) +
  scale_fill_manual(values = c("MG" = "#2563eb", "SP" = "#f59e0b")) +
  labs(
    title = "Déficit de Representatividade entre Eleitos por Porte Municipal (2024)",
    subtitle = "Valores negativos indicam sub-representação em pontos percentuais (pp) frente ao Censo 2022",
    x = "Porte Populacional do Município", y = "Gap de Representatividade (pp)", fill = "Estado (UF)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 15, hjust = 1), legend.position = "bottom")

salvar_e_exibir_plotly(g9, "09_gap_representatividade_porte_uf.html", tooltip = c("x", "y", "fill"))
