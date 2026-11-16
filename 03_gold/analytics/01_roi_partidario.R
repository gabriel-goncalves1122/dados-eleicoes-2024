# ==============================================================================
# VISUALIZA��O 01: ROI PARTID�RIO (ELEI��ES MUNICIPAIS 2024 - MG & SP)
# ==============================================================================
# Analisa o retorno eleitoral (votos por R$ gasto e taxa de sucesso) para Prefeitos.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(plotly)

# 1. Carregar Datamart Ouro 2024
datamart <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet")

# 2. Preparar Dados: Agrupamento por Partido para o cargo de Prefeito
roi_partidos <- datamart %>%
  filter(CD_CARGO == "11") %>% # 11 = Prefeito
  group_by(SG_PARTIDO) %>%
  summarise(
    Total_Candidatos = n(),
    Total_Eleitos = sum(Status_Eleicao == "Eleito", na.rm = TRUE),
    Taxa_Sucesso = (Total_Eleitos / Total_Candidatos) * 100,
    Total_Gasto_Partido = sum(Total_Gasto, na.rm = TRUE),
    Total_Votos_Partido = sum(Total_Votos, na.rm = TRUE),
    Custo_Medio_Voto = ifelse(Total_Votos_Partido > 0, Total_Gasto_Partido / Total_Votos_Partido, 0),
    Pct_Fundo_Publico_Medio = mean(Pct_Fundo_Publico, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  filter(Total_Candidatos >= 10) # Filtrar partidos com amostra m�nima representativa

# 3. Plotagem do Gr�fico de Quadrantes (Scatterplot)
g1 <- ggplot(roi_partidos, aes(
  x = Custo_Medio_Voto, y = Taxa_Sucesso, 
  size = Total_Eleitos, color = Pct_Fundo_Publico_Medio, 
  text = paste(
    "Partido:", SG_PARTIDO,
    "<br>Custo M�dio/Voto: R$", round(Custo_Medio_Voto, 2),
    "<br>Prefeitos Eleitos:", Total_Eleitos,
    "<br>Taxa Sucesso:", round(Taxa_Sucesso, 1), "%",
    "<br>% Fundo P�blico:", round(Pct_Fundo_Publico_Medio, 1), "%"
  )
)) +
  geom_point(alpha = 0.8) +
  geom_text(aes(label = SG_PARTIDO), size = 3, vjust = -1.5, color = "black", check_overlap = TRUE) +
  scale_x_log10(labels = scales::dollar_format(prefix = "R$")) +
  scale_color_viridis_c(option = "magma", direction = -1) +
  geom_hline(yintercept = median(roi_partidos$Taxa_Sucesso), linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = median(roi_partidos$Custo_Medio_Voto), linetype = "dashed", color = "gray50") +
  labs(
    title = "ROI Partid�rio - Elei��es Municipais 2024 (MG & SP)",
    subtitle = "Disputa para Prefeito: Taxa de Sucesso vs Custo M�dio por Voto",
    x = "Custo M�dio por Voto (R$ - Escala Log)",
    y = "Taxa de Sucesso (% de Prefeitos Eleitos)",
    color = "% Fundo P�blico",
    size = "Qtd. Eleitos"
  ) +
  theme_minimal()

# 4. Exibir no RStudio (Viewer)
p1 <- ggplotly(g1, tooltip = "text")
print(p1)
