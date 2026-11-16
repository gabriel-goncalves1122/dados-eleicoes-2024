# ==============================================================================
# ANALYTICS 03: PATRIMÔNIO DECLARADO VS. VOTOS OBTIDOS (2024 - MG & SP)
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

datamart <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet")

patrimonio_df <- datamart %>%
  filter(total_patrimonio_declarado > 1000, total_votos > 10, cd_cargo == 11L) %>%
  mutate(resultado = ifelse(is_eleito, "Eleito", "Não Eleito"))

g3 <- ggplot(patrimonio_df, aes(
  x = total_patrimonio_declarado, y = total_votos, color = resultado,
  text = paste(
    "Candidato:", nm_urna_candidato,
    "<br>Município:", nm_municipio, "-", sg_uf,
    "<br>Partido:", sg_partido,
    "<br>Patrimônio: R$", format(round(total_patrimonio_declarado, 0), big.mark = "."),
    "<br>Votos:", format(total_votos, big.mark = "."),
    "<br>Resultado:", status_eleicao
  )
)) +
  geom_point(alpha = 0.65, size = 2) +
  scale_x_log10(labels = dollar_format(prefix = "R$ ")) +
  scale_y_log10(labels = label_number(big.mark = ".")) +
  scale_color_manual(values = c("Eleito" = "#10b981", "Não Eleito" = "#64748b")) +
  labs(
    title = "Patrimônio Declarado vs. Votação para Prefeito (2024 - MG & SP)",
    x = "Patrimônio Declarado (R$ - Escala Log)",
    y = "Total de Votos (Escala Log)",
    color = "Situação"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g3, "03_patrimonio_vs_votos.html")
