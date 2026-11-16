# ==============================================================================
# ANALYTICS 10: FAIXAS DE DEPENDÊNCIA DO SETOR PÚBLICO vs. CUSTO ELEITORAL
# ==============================================================================
# Agrupa os 1.498 municípios em 4 faixas de peso da Administração Pública no PIB
# e compara o Gasto de Campanha por Habitante (R$) e o Custo por Voto (R$).

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

df_mun <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet") %>%
  filter(!is.na(pct_adm_publica_vab_2021), !is.na(gasto_campanha_per_capita)) %>%
  mutate(
    faixa_dependencia = case_when(
      pct_adm_publica_vab_2021 < 15 ~ "1. Baixa (<15% do VAB)",
      pct_adm_publica_vab_2021 < 30 ~ "2. Moderada (15% a 30%)",
      pct_adm_publica_vab_2021 < 45 ~ "3. Alta (30% a 45%)",
      TRUE ~ "4. Muito Alta (>45% do VAB)"
    ),
    faixa_dependencia = factor(faixa_dependencia, levels = c(
      "1. Baixa (<15% do VAB)", "2. Moderada (15% a 30%)",
      "3. Alta (30% a 45%)", "4. Muito Alta (>45% do VAB)"
    ))
  ) %>%
  group_by(sg_uf, faixa_dependencia) %>%
  summarise(
    qtd_municipios = n(),
    gasto_pc_mediano = median(gasto_campanha_per_capita, na.rm = TRUE),
    custo_voto_mediano = median(custo_medio_voto_municipio, na.rm = TRUE),
    fundo_pub_medio = mean(pct_fundo_publico_municipio, na.rm = TRUE),
    .groups = "drop"
  )

g10 <- ggplot(df_mun, aes(
  x = faixa_dependencia, y = gasto_pc_mediano, fill = sg_uf,
  text = paste(
    "Estado:", sg_uf,
    "<br>Faixa Adm. Pública:", faixa_dependencia,
    "<br>Municípios na Faixa:", qtd_municipios,
    "<br>Gasto Mediano/Habitante: R$", round(gasto_pc_mediano, 2),
    "<br>Custo Mediano/Voto: R$", round(custo_voto_mediano, 2),
    "<br>% Fundo Público:", round(fundo_pub_medio, 1), "%"
  )
)) +
  geom_col(position = position_dodge(width = 0.72), width = 0.65) +
  scale_y_continuous(labels = dollar_format(prefix = "R$ ")) +
  scale_fill_manual(values = c("MG" = "#2563eb", "SP" = "#f59e0b")) +
  labs(
    title = "Quanto Mais o Município Depende da Prefeitura, Mais Cara é a Campanha por Habitante",
    subtitle = "Gasto mediano de campanha por habitante (R$) segundo o peso da Administração Pública no VAB",
    x = "Grau de Dependência da Administração Pública na Economia Local (IBGE)",
    y = "Gasto de Campanha por Habitante (R$)",
    fill = "Estado (UF)"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g10, "10_economia_publica_vs_campanhas.html")
