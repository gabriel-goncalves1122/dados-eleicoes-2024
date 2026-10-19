# ==============================================================================
# VISUALIZAÇÃO 04: TOP 20 PARTIDOS (Volume de Dinheiro Público vs Privado)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(plotly)

# 1. Carregar Datamart Ouro
datamart <- read_parquet("tse/data/03_gold/parquet/datamart_candidatos_2022.parquet")

# 2. Agrupamento por Partido e Top 20
top_partidos <- datamart %>%
  group_by(SG_PARTIDO) %>%
  summarise(
    Arrecadacao_Publica = sum(Total_Fundo_Publico, na.rm = TRUE),
    Arrecadacao_Total = sum(Total_Arrecadado, na.rm = TRUE),
    Arrecadacao_Privada = Arrecadacao_Total - Arrecadacao_Publica
  ) %>%
  arrange(desc(Arrecadacao_Total)) %>%
  head(20)

# Para usar barras empilhadas, precisamos transformar os dados de formato "Largo" para "Longo"
partidos_long <- top_partidos %>%
  select(SG_PARTIDO, Arrecadacao_Publica, Arrecadacao_Privada, Arrecadacao_Total) %>%
  pivot_longer(
    cols = c("Arrecadacao_Publica", "Arrecadacao_Privada"),
    names_to = "Origem",
    values_to = "Valor"
  ) %>%
  # Limpar nomes para legenda
  mutate(Origem = str_replace(Origem, "Arrecadacao_", "Origem: ")) %>%
  # Ordenar os fatores para o gráfico ficar ordenado do maior pro menor
  mutate(SG_PARTIDO = reorder(SG_PARTIDO, Arrecadacao_Total))

# 3. Plotagem
g4 <- ggplot(partidos_long, aes(x = Valor, y = SG_PARTIDO, fill = Origem,
                                text = paste("Partido:", SG_PARTIDO,
                                             "<br>", Origem, ":", scales::dollar(Valor, prefix="R$"),
                                             "<br>Arrecadação Total:", scales::dollar(Arrecadacao_Total, prefix="R$")))) +
  geom_col(alpha = 0.9) +
  scale_fill_manual(values = c("Origem: Publica" = "#c0392b", "Origem: Privada" = "#2980b9")) +
  scale_x_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale(), prefix="R$ ")) +
  labs(
    title = "Top 20 Partidos: A Máquina de Arrecadação",
    subtitle = "De onde vem o dinheiro? (Público vs Privado)",
    x = "Volume Total Arrecadado (R$)",
    y = "Partido",
    fill = "Tipo de Fundo"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# 4. Exibir no RStudio (Viewer)
p4 <- ggplotly(g4, tooltip = "text")
print(p4)
