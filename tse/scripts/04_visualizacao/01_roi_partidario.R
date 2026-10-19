# ==============================================================================
# VISUALIZAÇÃO 01: ROI PARTIDÁRIO (MÁQUINAS DE ELEIÇÃO VS CABIDES DE EMPREGO)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(plotly)

# 1. Carregar Datamart Ouro
datamart <- read_parquet("tse/data/03_gold/parquet/datamart_candidatos_2022.parquet")

# 2. Preparar Dados: Agrupamento por Partido
# Filtro: Apenas candidatos a Deputado Federal (para ter uma comparação justa de cargo)
roi_partidos <- datamart %>%
  filter(str_detect(DS_CARGO, "DEPUTADO FEDERAL")) %>%
  group_by(SG_PARTIDO) %>%
  summarise(
    Total_Candidatos = n(),
    Total_Eleitos = sum(Status_Eleicao == "Eleito", na.rm = TRUE),
    Taxa_Sucesso = (Total_Eleitos / Total_Candidatos) * 100,
    Total_Gasto_Partido = sum(Total_Gasto, na.rm = TRUE),
    Total_Votos_Partido = sum(Total_Votos, na.rm = TRUE),
    Custo_Medio_Voto = Total_Gasto_Partido / Total_Votos_Partido,
    Pct_Fundo_Publico_Medio = mean(Pct_Fundo_Publico, na.rm = TRUE) * 100
  ) %>%
  filter(Total_Votos_Partido > 100000) # Filtrar partidos muito pequenos (ruído)

# 3. Plotagem do Gráfico de Quadrantes (Scatterplot)
g1 <- ggplot(roi_partidos, aes(x = Custo_Medio_Voto, y = Taxa_Sucesso, 
                               size = Total_Eleitos, color = Pct_Fundo_Publico_Medio, 
                               text = paste("Partido:", SG_PARTIDO,
                                            "<br>Custo/Voto: R$", round(Custo_Medio_Voto, 2),
                                            "<br>Eleitos:", Total_Eleitos,
                                            "<br>Taxa Sucesso:", round(Taxa_Sucesso, 1), "%",
                                            "<br>% Fundo Público:", round(Pct_Fundo_Publico_Medio, 1), "%"))) +
  geom_point(alpha = 0.8) +
  geom_text(aes(label = SG_PARTIDO), size = 3, vjust = -1.5, color = "black", check_overlap = TRUE) +
  scale_x_log10(labels = scales::dollar_format(prefix = "R$")) +
  scale_color_viridis_c(option = "magma", direction = -1) +
  geom_hline(yintercept = median(roi_partidos$Taxa_Sucesso), linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = median(roi_partidos$Custo_Medio_Voto), linetype = "dashed", color = "gray50") +
  labs(
    title = "ROI Partidário - Deputados Federais 2022",
    subtitle = "Quadrante Superior Esquerdo = Máquinas Eficientes (Muito Sucesso, Custo Baixo)",
    x = "Custo Médio por Voto (R$ - Escala Log)",
    y = "Taxa de Sucesso (% de Eleitos)",
    color = "% Fundo Público",
    size = "Qtd. Eleitos"
  ) +
  theme_minimal()

# 4. Exibir no RStudio (Viewer)
p1 <- ggplotly(g1, tooltip = "text")
print(p1)
