# ==============================================================================
# ANALYTICS 02: DESIGUALDADE NO FUNDO PÚBLICO POR COR/RAÇA E GÊNERO
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

datamart <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet")

desigualdade_df <- datamart %>%
  filter(total_fundo_publico > 0, !is.na(ds_cor_raca), !is.na(ds_genero)) %>%
  filter(ds_cor_raca %in% c("BRANCA", "PARDA", "PRETA", "AMARELA", "INDÍGENA")) %>%
  mutate(ds_cor_raca = factor(ds_cor_raca, levels = c("BRANCA", "PARDA", "PRETA", "AMARELA", "INDÍGENA")))

g2 <- ggplot(desigualdade_df, aes(
  x = ds_cor_raca, y = total_fundo_publico, fill = ds_genero
)) +
  geom_violin(
    position = position_dodge(width = 0.8),
    alpha = 0.78, trim = FALSE, color = "#334155", linewidth = 0.35
  ) +
  geom_boxplot(
    position = position_dodge(width = 0.8),
    width = 0.14, alpha = 0.9, outlier.shape = NA, color = "#0f172a", linewidth = 0.4
  ) +
  scale_y_log10(labels = dollar_format(prefix = "R$ ")) +
  scale_fill_manual(values = c("MASCULINO" = "#0284c7", "FEMININO" = "#db2777")) +
  labs(
    title = "Distribuição do Fundo Público por Cor/Raça e Gênero (2024 - MG & SP)",
    subtitle = "Densidade (Violin Plot) e mediana dos recursos públicos recebidos (Escala Logarítmica)",
    x = "Cor / Raça Declarada",
    y = "Total de Fundo Público Recebido (R$)",
    fill = "Gênero"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g2, "02_desigualdade_fundo.html", tooltip = c("x", "y", "fill"))
