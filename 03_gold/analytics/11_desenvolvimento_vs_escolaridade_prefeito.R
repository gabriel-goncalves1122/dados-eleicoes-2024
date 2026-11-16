# ==============================================================================
# ANALYTICS 11: DESENVOLVIMENTO HUMANO VS. ESCOLARIDADE DO PREFEITO ELEITO
# ==============================================================================
# Responde: Municípios com maior alfabetização e saneamento elegem prefeitos
# com maior grau de instrução formal em MG e SP?

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

df_mun <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet") %>%
  filter(!is.na(prefeito_eleito_instrucao), !is.na(taxa_alfabetizacao_15mais)) %>%
  mutate(
    instrucao_grupo = case_when(
      prefeito_eleito_instrucao == "SUPERIOR COMPLETO" ~ "Superior Completo",
      prefeito_eleito_instrucao %in% c("SUPERIOR INCOMPLETO", "ENSINO MÉDIO COMPLETO") ~ "Médio Completo / Sup. Inc.",
      TRUE ~ "Até Médio Incompleto"
    ),
    instrucao_grupo = factor(instrucao_grupo, levels = c(
      "Até Médio Incompleto", "Médio Completo / Sup. Inc.", "Superior Completo"
    ))
  )

g11 <- ggplot(df_mun, aes(
  x = instrucao_grupo, y = taxa_alfabetizacao_15mais, fill = sg_uf
)) +
  geom_boxplot(alpha = 0.75, outlier.alpha = 0.25) +
  scale_fill_manual(values = c("MG" = "#2563eb", "SP" = "#f59e0b")) +
  labs(
    title = "Taxa de Alfabetização Municipal (Censo 2022) vs. Escolaridade do Prefeito Eleito",
    subtitle = "Comparativo dos 1.498 municípios de MG e SP",
    x = "Escolaridade do Prefeito Eleito (2024)",
    y = "Taxa de Alfabetização 15+ anos (% - IBGE)",
    fill = "Estado (UF)"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g11, "11_desenvolvimento_vs_escolaridade_prefeito.html", tooltip = c("x", "y", "fill"))
