# ==============================================================================
# ANALYTICS 00: EXPLORA��O INTERATIVA DOS DADOS (ELEI��ES 2024 - MG & SP)
# ==============================================================================
# Script r�pido para explora��o visual no Viewer do RStudio.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(reactable)
library(plotly)

# ------------------------------------------------------------------------------
# 1. CARREGANDO OS DADOS SALVOS (Via Apache Arrow)
# ------------------------------------------------------------------------------
message("Carregando bases anal�ticas...")

candidatos_path <- "03_gold/data/datamart_candidatos_2024.parquet"
if (!file.exists(candidatos_path)) {
  candidatos_path <- "02_silver/data/tse/candidatos_clean.parquet"
}

candidatos <- read_parquet(candidatos_path)
populacao <- read_parquet("01_bronze/data/ibge/populacao_2022.parquet")
pib <- read_parquet("01_bronze/data/ibge/pib_municipal.parquet")

# ------------------------------------------------------------------------------
# 2. TABELAS INTERATIVAS (Explore os dados direto no RStudio)
# ------------------------------------------------------------------------------

# Tabela 1: Resumo Demogr�fico dos Candidatos por G�nero e Partido
tabela_genero_partido <- candidatos %>%
  group_by(SG_PARTIDO, DS_GENERO) %>%
  summarise(Total = n(), .groups = "drop") %>%
  pivot_wider(names_from = DS_GENERO, values_from = Total, values_fill = 0) %>%
  mutate(Total_Geral = rowSums(across(where(is.numeric)))) %>%
  arrange(desc(Total_Geral))

print(reactable(tabela_genero_partido, 
                searchable = TRUE, 
                striped = TRUE, 
                highlight = TRUE,
                defaultPageSize = 10,
                theme = reactableTheme(
                  borderColor = "#dfe2e5",
                  stripedColor = "#f6f8fa",
                  highlightColor = "#f0f5f9"
                )))

# Tabela 2: Munic�pios mais Ricos vs Popula��o (IBGE)
ibge_junto <- populacao %>%
  inner_join(pib, by = "codigo_ibge") %>%
  mutate(PIB_Per_Capita = pib / populacao) %>%
  arrange(desc(PIB_Per_Capita))

print(reactable(ibge_junto %>% head(100), searchable = TRUE))

# ------------------------------------------------------------------------------
# 3. GR�FICOS (ggplot2 + plotly)
# ------------------------------------------------------------------------------

# Gr�fico 1: Propor��o de Ra�a/Cor dos Candidatos (2024 - MG & SP)
grafico_raca <- candidatos %>%
  count(DS_COR_RACA) %>%
  mutate(DS_COR_RACA = fct_reorder(DS_COR_RACA, n)) %>%
  ggplot(aes(x = n, y = DS_COR_RACA, fill = DS_COR_RACA)) +
  geom_col(show.legend = FALSE) +
  theme_minimal() +
  labs(
    title = "Distribui��o de Ra�a/Cor dos Candidatos (Elei��es 2024 - MG & SP)",
    x = "N�mero de Candidatos",
    y = ""
  ) +
  scale_fill_viridis_d(option = "magma")

print(ggplotly(grafico_raca))

message("? Script executado! Confira a aba 'Viewer' no seu RStudio para ver as Tabelas e Gr�ficos Interativos.")
