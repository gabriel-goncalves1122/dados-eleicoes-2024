# ==============================================================================
# ANALYTICS 02: DESIGUALDADE NO FUNDO PÚBLICO (VIOLIN PLOT NATIVO PLOTLY)
# ==============================================================================
# Violin plot nativo sem caixa central e sem sobreposição entre os lados.

if (file.exists("src/config.R")) {
  source("src/config.R")
} else {
  source("../../src/config.R")
}
source("analises/eleicoes/_helpers_vis.R")

datamart <- read_parquet("dados/ouro/datamart_candidatos_2024.parquet")

desigualdade_df <- datamart %>%
  filter(total_fundo_publico >= 100, !is.na(ds_cor_raca), !is.na(ds_genero)) %>%
  filter(ds_cor_raca %in% c("BRANCA", "PARDA", "PRETA", "AMARELA", "INDÍGENA")) %>%
  mutate(
    ds_cor_raca = factor(ds_cor_raca, levels = c("BRANCA", "PARDA", "PRETA", "AMARELA", "INDÍGENA")),
    log_fundo = log10(total_fundo_publico)
  )

p2 <- plot_ly(
  data = desigualdade_df,
  x = ~ds_cor_raca,
  y = ~log_fundo,
  split = ~ds_genero,
  type = "violin",
  box = list(visible = FALSE),
  meanline = list(visible = TRUE, color = "#ffffff", width = 2),
  points = FALSE,
  spanmode = "hard",
  scalemode = "width",
  width = 0.75,
  color = ~ds_genero,
  colors = c("FEMININO" = "#e11d48", "MASCULINO" = "#0284c7"),
  alpha = 0.82
) %>%
  layout(
    title = list(
      text = "<b>Distribuição do Fundo Público por Cor/Raça e Gênero (2024 - MG & SP)</b><br><sup>Densidade suavizada (Violin Plot) com linha da média — sem caixa central</sup>"
    ),
    violinmode = "group",
    violingap = 0.22,
    violingroupgap = 0.15,
    xaxis = list(title = "Cor / Raça Declarada"),
    yaxis = list(
      title = "Total de Fundo Público Recebido (Escala Log)",
      tickvals = c(2, 3, 4, 5, 6, 7),
      ticktext = c("R$ 100", "R$ 1 mil", "R$ 10 mil", "R$ 100 mil", "R$ 1 Mi", "R$ 10 Mi")
    ),
    legend = list(orientation = "h", x = 0.35, y = -0.15)
  )

salvar_e_exibir_plotly(p2, "02_desigualdade_fundo.html")
