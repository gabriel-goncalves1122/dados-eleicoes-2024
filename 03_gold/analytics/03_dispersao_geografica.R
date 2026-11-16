# ==============================================================================
# VISUALIZA��O 03: DISPERS�O ELEITORAL - VOTOS VS PATRIM�NIO (ELEI��ES 2024 - MG & SP)
# ==============================================================================
# Analisa se o patrim�nio pessoal declarado influencia o total de votos obtidos.

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

# 2. Filtrar Candidatos a Prefeito com vota��o expressiva
dispersao_df <- datamart %>%
  filter(CD_CARGO == "11") %>% # Prefeito
  filter(Total_Votos > 500) %>%
  mutate(
    Faixa_Patrimonio = case_when(
      Total_Patrimonio_Declarado == 0 ~ "Sem Bens Declarados",
      Total_Patrimonio_Declarado < 500000 ~ "At� R$ 500 mil",
      Total_Patrimonio_Declarado < 2000000 ~ "R$ 500k a R$ 2M",
      TRUE ~ "Mais de R$ 2 Milh�es"
    )
  )

# 3. Plotagem
g3 <- ggplot(dispersao_df, aes(
  x = Total_Patrimonio_Declarado + 1, y = Total_Votos, color = Status_Eleicao,
  text = paste(
    "Candidato:", NM_URNA_CANDIDATO,
    "<br>Munic�pio:", NM_UE, "-", SG_UF,
    "<br>Partido:", SG_PARTIDO,
    "<br>Patrim�nio:", scales::dollar(Total_Patrimonio_Declarado, prefix = "R$ "),
    "<br>Total Votos:", Total_Votos,
    "<br>Gasto:", scales::dollar(Total_Gasto, prefix = "R$ ")
  )
)) +
  geom_point(alpha = 0.6) +
  scale_x_log10(labels = scales::dollar_format(prefix = "R$ ")) +
  scale_y_log10(labels = scales::comma_format(big.mark = ".", decimal.mark = ",")) +
  scale_color_manual(values = c("Eleito" = "#27ae60", "2� Turno" = "#f39c12", "N�o Eleito" = "#c0392b")) +
  labs(
    title = "Candidatos a Prefeito: Patrim�nio Declarado vs Votos (2024 - MG & SP)",
    subtitle = "Influ�ncia do patrim�nio pessoal no desempenho de votos nas urnas",
    x = "Patrim�nio Pessoal Declarado (R$ - Escala Log)",
    y = "Total de Votos (Escala Log)",
    color = "Situa��o"
  ) +
  theme_minimal()

# 4. Exibir no RStudio (Viewer)
p3 <- ggplotly(g3, tooltip = "text")
print(p3)
