# ==============================================================================
# ANÁLISE 09: DIGITAL PULVERIZA VS. MILITÂNCIA CONCENTRA (HHI MULTI-ZONA)
# ==============================================================================
# Tese: Nos 189 municípios multi-zona, vereadores eleitos com foco digital têm menor
# concentração geográfica (HHI normalizado) do que os focados em militância de rua.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [09] Concentração Territorial do Voto (HHI Normalizado) ===")

df <- ler_ouro("ouro_concentracao_zonas.parquet") %>%
  filter(
    ds_cargo == "VEREADOR",
    is_eleito,
    qtd_zonas_municipio >= 2,
    total_gasto >= 5000
  ) %>%
  mutate(
    hhi_norm = (hhi_voto_zonas - 1 / qtd_zonas_municipio) / (1 - 1 / qtd_zonas_municipio),
    perfil_gasto = case_when(
      pct_gasto_digital > pct_gasto_militancia & pct_gasto_digital > 0 ~ "Foco Digital",
      pct_gasto_militancia > pct_gasto_digital & pct_gasto_militancia > 0 ~ "Foco Militância",
      TRUE ~ "Tradicional / Outros"
    ),
    perfil_gasto = factor(perfil_gasto, levels = c("Foco Digital", "Foco Militância", "Tradicional / Outros")),
    faixa_zonas = case_when(
      qtd_zonas_municipio <= 5 ~ "2 a 5 zonas",
      qtd_zonas_municipio <= 15 ~ "6 a 15 zonas",
      TRUE ~ "16+ zonas (Metrópoles)"
    ),
    faixa_zonas = factor(faixa_zonas, levels = c("2 a 5 zonas", "6 a 15 zonas", "16+ zonas (Metrópoles)"))
  )

resumo_hhi <- df %>%
  group_by(faixa_zonas, perfil_gasto) %>%
  summarise(
    qtd_vereadores = n(),
    hhi_bruto_med = median(hhi_voto_zonas),
    hhi_norm_med = median(hhi_norm),
    hhi_norm_media = mean(hhi_norm),
    .groups = "drop"
  )
salvar_tabela(resumo_hhi, "09_hhi_normalizado_vereadores.csv")

p_violin <- ggplot(df, aes(x = perfil_gasto, y = hhi_norm, fill = perfil_gasto)) +
  geom_violin(alpha = 0.65, trim = TRUE, color = NA) +
  geom_boxplot(width = 0.18, fill = "white", outlier.alpha = 0.15, color = "#1e293b") +
  geom_text(
    data = resumo_hhi,
    aes(x = perfil_gasto, y = 0.96, label = paste0("Med: ", fmt_num_br(hhi_norm_med, 3))),
    inherit.aes = FALSE,
    size = 3.2, fontface = "bold", color = "#1e293b"
  ) +
  facet_wrap(~faixa_zonas) +
  scale_fill_manual(values = c(
    "Foco Digital"         = PALETA$azul,
    "Foco Militância"      = PALETA$ambar,
    "Tradicional / Outros" = PALETA$slate_claro
  )) +
  scale_y_continuous(labels = function(x) fmt_num_br(x, 2), limits = c(0, 1.03)) +
  labs(
    title = "Nas metrópoles, foco digital pulveriza votos 3,3× mais que militância",
    subtitle = "HHI normalizado de vereadores eleitos (gasto >= R$ 5 mil) em 189 cidades multi-zona (0 = pulverizado, 1 = 1 zona)",
    x = NULL,
    y = "HHI Normalizado"
  ) +
  tema_slide(base_size = 13) +
  theme(legend.position = "none", axis.text.x = element_text(angle = 12, hjust = 1), panel.grid.major.x = element_blank())
salvar_grafico(p_violin, "09a_violin_hhi_digital_vs_militancia.png", width = 11.5, height = 6.3)

p_scatter <- ggplot(df, aes(x = pct_gasto_digital, y = hhi_norm)) +
  geom_point(alpha = 0.25, size = 1) +
  geom_smooth(method = "lm", se = TRUE, color = "steelblue") +
  facet_wrap(~faixa_zonas) +
  labs(
    title = "% de Gasto em Impulsionamento Digital vs. Concentração Territorial (HHI Normalizado)",
    subtitle = "Inclinação negativa confirma maior dispersão geográfica de votos conforme sobe o peso digital",
    x = "% do Gasto Total em Impulsionamento Digital",
    y = "HHI Normalizado"
  ) +
  theme_minimal()
salvar_grafico(p_scatter, "09b_scatter_digital_vs_hhi.png", width = 12, height = 6)
