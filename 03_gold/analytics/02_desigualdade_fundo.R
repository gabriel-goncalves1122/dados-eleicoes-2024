# ==============================================================================
# VISUALIZA��O 02: DESIGUALDADE NO FUNDO P�BLICO (ELEI��ES 2024 - MG & SP)
# ==============================================================================
# Distribui��o do Fundo Eleitoral por Cor/Ra�a e G�nero nas campanhas municipais.

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

# 2. Preparar Dados: Candidatos que receberam fundo p�blico
desigualdade_df <- datamart %>%
  filter(Total_Fundo_Publico > 0) %>%
  filter(DS_COR_RACA != "#NULO" & DS_COR_RACA != "N�O DIVULG�VEL") %>%
  filter(DS_COR_RACA %in% c("BRANCA", "PRETA", "PARDA", "IND�GENA", "AMARELA")) %>%
  mutate(DS_COR_RACA = factor(DS_COR_RACA, levels = c("BRANCA", "PARDA", "PRETA", "AMARELA", "IND�GENA")))

# 3. Plotagem do Boxplot com Escala Logar�tmica
g2 <- ggplot(desigualdade_df, aes(
  x = DS_COR_RACA, y = Total_Fundo_Publico, fill = DS_GENERO,
  text = paste(
    "Candidato:", NM_URNA_CANDIDATO,
    "<br>Cargo:", DS_CARGO,
    "<br>Munic�pio:", NM_UE, "-", SG_UF,
    "<br>Fundo: R$", format(Total_Fundo_Publico, big.mark = ".", decimal.mark = ","),
    "<br>Status:", Status_Eleicao
  )
)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.3) +
  scale_y_log10(labels = scales::dollar_format(prefix = "R$")) +
  scale_fill_manual(values = c("MASCULINO" = "#2c3e50", "FEMININO" = "#e74c3c")) +
  labs(
    title = "Desigualdade na Distribui��o do Fundo P�blico (Elei��es 2024 - MG & SP)",
    subtitle = "Volume financeiro p�blico por Cor/Ra�a e G�nero (Escala Logar�tmica)",
    x = "Cor / Ra�a Declarada",
    y = "Total de Fundo P�blico Recebido (R$)",
    fill = "G�nero"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# 4. Exibir no RStudio (Viewer)
p2 <- ggplotly(g2, tooltip = "text")
print(p2)
