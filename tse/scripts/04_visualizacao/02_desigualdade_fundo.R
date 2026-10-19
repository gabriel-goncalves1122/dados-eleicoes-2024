# ==============================================================================
# VISUALIZAÇÃO 02: DESIGUALDADE NO FUNDO PÚBLICO (COR E GÊNERO)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(plotly)

# 1. Carregar Datamart Ouro
datamart <- read_parquet("tse/data/03_gold/parquet/datamart_candidatos_2022.parquet")

# 2. Preparar Dados: Filtrar Deputados Federais que receberam fundo público
desigualdade_df <- datamart %>%
  filter(str_detect(DS_CARGO, "DEPUTADO FEDERAL")) %>%
  filter(Total_Fundo_Publico > 0) %>% # Apenas quem recebeu algum fundo
  filter(DS_COR_RACA != "#NULO" & DS_COR_RACA != "NÃO DIVULGÁVEL") %>%
  # Limitar a grupos representativos para não poluir o gráfico
  filter(DS_COR_RACA %in% c("BRANCA", "PRETA", "PARDA")) %>%
  mutate(DS_COR_RACA = factor(DS_COR_RACA, levels = c("BRANCA", "PARDA", "PRETA")))

# 3. Plotagem do Boxplot com Escala Logarítmica
g2 <- ggplot(desigualdade_df, aes(x = DS_COR_RACA, y = Total_Fundo_Publico, fill = DS_GENERO,
                                  text = paste("Candidato:", NM_URNA_CANDIDATO,
                                               "<br>Fundo: R$", format(Total_Fundo_Publico, big.mark=".", decimal.mark=","),
                                               "<br>Eleito:", Status_Eleicao))) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.4) +
  scale_y_log10(labels = scales::dollar_format(prefix = "R$")) +
  scale_fill_manual(values = c("MASCULINO" = "#2c3e50", "FEMININO" = "#e74c3c")) +
  labs(
    title = "Desigualdade na Distribuição do Fundo Público (Dep. Federal)",
    subtitle = "Distribuição do volume recebido em reais (Escala Logarítmica)",
    x = "Cor / Raça Declarada",
    y = "Total de Fundo Público Recebido (R$)",
    fill = "Gênero"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# 4. Exibir no RStudio (Viewer)
p2 <- ggplotly(g2, tooltip = "text")
print(p2)
