# ==============================================================================
# ANÁLISE 02: O PARADOXO DA MÁQUINA PÚBLICA (VAB ADM. PÚBLICA VS. GASTO PER CAPITA)
# ==============================================================================
# Tese: Em pequenos municípios (<20k hab.), maior dependência do setor público
# na economia local está associada a eleições proporcionais mais caras por habitante.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [02] O Paradoxo da Máquina Pública ===")

df <- ler_ouro("ouro_pca_municipios.parquet") %>%
  filter(!is.na(pct_adm_publica_vab_2021), !is.na(gasto_campanha_per_capita), !is.na(porte_municipio)) %>%
  mutate(
    porte_municipio = fct_relevel(
      porte_municipio,
      "Pequeno Porte I (<20k)", "Pequeno Porte II (20k-50k)",
      "Médio Porte (50k-100k)", "Grande Porte (100k-500k)", "Metrópole (>500k)"
    ),
    faixa_dependencia = if_else(pct_adm_publica_vab_2021 >= 35, "Alta Dependência (>=35% VAB)", "Menor Dependência (<35% VAB)")
  )

resumo_porte <- df %>%
  group_by(porte_municipio) %>%
  summarise(
    n_municipios = n(),
    corr_pearson = cor(pct_adm_publica_vab_2021, gasto_campanha_per_capita),
    corr_spearman = cor(pct_adm_publica_vab_2021, gasto_campanha_per_capita, method = "spearman"),
    med_gasto_pc_alta_adm = median(gasto_campanha_per_capita[pct_adm_publica_vab_2021 >= 35], na.rm = TRUE),
    med_gasto_pc_baixa_adm = median(gasto_campanha_per_capita[pct_adm_publica_vab_2021 < 20], na.rm = TRUE),
    .groups = "drop"
  )
salvar_tabela(resumo_porte, "02_paradoxo_maquina_publica.csv")

lim_p98 <- quantile(df$gasto_campanha_per_capita, 0.98, na.rm = TRUE)

p_hex <- df %>%
  filter(gasto_campanha_per_capita <= lim_p98) %>%
  ggplot(aes(x = pct_adm_publica_vab_2021, y = gasto_campanha_per_capita)) +
  geom_bin2d(bins = 30) +
  geom_smooth(method = "loess", se = TRUE, color = "red", linewidth = 0.9) +
  facet_wrap(~porte_municipio, scales = "free_y") +
  scale_fill_viridis_c(trans = "log10") +
  labs(
    title = "Dependência da Máquina Pública (VAB) vs. Gasto Eleitoral per Capita",
    subtitle = "Densidade 2D + tendência local (LOESS) por porte populacional (eixo Y limitado ao P98)",
    x = "% da Administração Pública no VAB Municipal (IBGE 2021)",
    y = "Gasto Total de Campanha per Capita (R$ / hab.)",
    fill = "Nº Municípios"
  ) +
  theme_minimal()
salvar_grafico(p_hex, "02_paradoxo_maquina_publica_bin2d.png", width = 12, height = 7)
