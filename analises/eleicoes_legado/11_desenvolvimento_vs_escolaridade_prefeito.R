# ==============================================================================
# ANALYTICS 11: ESCOLARIDADE E TAXA DE SUCESSO NAS ELEIÇÕES MUNICIPAIS (2024)
# ==============================================================================
# Mostra a taxa de vitória (%) dos candidatos segundo o grau de instrução
# formal para Prefeito e Vereador em MG e SP.

if (file.exists("src/config.R")) {
  source("src/config.R")
} else {
  source("../../src/config.R")
}
source("analises/eleicoes/_helpers_vis.R")

cand <- read_parquet("dados/ouro/datamart_candidatos_2024.parquet") %>%
  filter(cd_cargo %in% c(11L, 13L), !is.na(ds_grau_instrucao)) %>%
  mutate(
    escolaridade = case_when(
      ds_grau_instrucao == "SUPERIOR COMPLETO" ~ "5. Superior Completo",
      ds_grau_instrucao == "SUPERIOR INCOMPLETO" ~ "4. Superior Incompleto",
      ds_grau_instrucao == "ENSINO MÉDIO COMPLETO" ~ "3. Ensino Médio Completo",
      ds_grau_instrucao %in% c("ENSINO MÉDIO INCOMPLETO", "ENSINO FUNDAMENTAL COMPLETO") ~ "2. Fund. Completo / Médio Inc.",
      TRUE ~ "1. Até Fundamental Incompleto"
    )
  ) %>%
  group_by(ds_cargo, escolaridade) %>%
  summarise(
    total_candidatos = n(),
    total_eleitos = sum(is_eleito, na.rm = TRUE),
    taxa_sucesso = (total_eleitos / total_candidatos) * 100,
    gasto_medio = mean(total_gasto, na.rm = TRUE),
    .groups = "drop"
  )

g11 <- ggplot(cand, aes(
  x = taxa_sucesso, y = escolaridade, fill = ds_cargo,
  text = paste(
    "Cargo:", ds_cargo,
    "<br>Escolaridade:", escolaridade,
    "<br>Eleitos:", format(total_eleitos, big.mark = "."), "de", format(total_candidatos, big.mark = "."),
    "<br>Taxa de Sucesso:", round(taxa_sucesso, 1), "%",
    "<br>Gasto Médio: R$", format(round(gasto_medio, 0), big.mark = ".")
  )
)) +
  geom_col(position = position_dodge(width = 0.72), width = 0.65) +
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  scale_fill_manual(values = c("PREFEITO" = "#0d9488", "VEREADOR" = "#6366f1")) +
  labs(
    title = "Taxa de Sucesso Eleitoral por Grau de Instrução dos Candidatos (2024)",
    subtitle = "Candidatos com Ensino Superior Completo têm a maior taxa de vitória para Prefeito e Vereador",
    x = "Taxa de Sucesso (% de Candidatos Eleitos)",
    y = NULL, fill = "Cargo"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g11, "11_desenvolvimento_vs_escolaridade_prefeito.html")
