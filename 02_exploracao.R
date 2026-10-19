# ==============================================================================
# FASE 2 e 3: EXPLORAÇÃO DOS DADOS E VISUALIZAÇÃO GRÁFICA
# ==============================================================================

# Definindo a pasta raiz do projeto (para garantir que os dados sejam lidos do lugar certo)

# Instale os pacotes extras caso não tenha (gráficos e tabelas interativas)
#install.packages(c("reactable", "plotly"))

library(tidyverse)
library(arrow)
library(reactable) # Para tabelas interativas bonitas
library(plotly)    # Para gráficos interativos

# ------------------------------------------------------------------------------
# 1. CARREGANDO OS DADOS SALVOS (Leitura ultra-rápida com arrow)
# ------------------------------------------------------------------------------
message("Carregando os arquivos Parquet...")

# Lemos os dados diretamente para a memória do R como dataframes
candidatos <- read_parquet("data/raw/tse_2022/candidatos.parquet")
# votacao <- read_parquet("data/raw/tse_2022/votacao_nominal.parquet") # Comentado temporariamente
populacao <- read_parquet("data/raw/ibge/populacao_2022.parquet")
pib <- read_parquet("data/raw/ibge/pib_municipal.parquet")

# ------------------------------------------------------------------------------
# 2. TABELAS INTERATIVAS (Explore os dados direto no RStudio)
# ------------------------------------------------------------------------------

# Tabela 1: Resumo Demográfico dos Candidatos
# Agrupamos para ver quantos candidatos cada partido lançou por gênero
tabela_genero_partido <- candidatos %>%
  group_by(SG_PARTIDO, DS_GENERO) %>%
  summarise(Total = n(), .groups = "drop") %>%
  pivot_wider(names_from = DS_GENERO, values_from = Total, values_fill = 0) %>%
  mutate(Total_Geral = rowSums(across(where(is.numeric)))) %>%
  arrange(desc(Total_Geral))

# Mostra uma tabela interativa no RStudio (Viewer)
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

# Tabela 2: Municípios mais Ricos vs População (Juntando bases do IBGE)
# O IBGE é fácil de juntar pois usam o mesmo código
ibge_junto <- populacao %>%
  inner_join(pib, by = c("codigo_ibge", "nome_municipio")) %>%
  mutate(PIB_Per_Capita = pib / populacao) %>%
  arrange(desc(PIB_Per_Capita))

print(reactable(ibge_junto %>% head(100), searchable = TRUE))

# ------------------------------------------------------------------------------
# 3. GRÁFICOS (ggplot2 + plotly)
# ------------------------------------------------------------------------------

# Gráfico 1: Proporção de Raça/Cor dos Candidatos em 2022
grafico_raca <- candidatos %>%
  count(DS_COR_RACA) %>%
  mutate(DS_COR_RACA = fct_reorder(DS_COR_RACA, n)) %>%
  ggplot(aes(x = n, y = DS_COR_RACA, fill = DS_COR_RACA)) +
  geom_col(show.legend = FALSE) +
  theme_minimal() +
  labs(
    title = "Distribuição de Raça/Cor dos Candidatos (2022)",
    x = "Número de Candidatos",
    y = ""
  ) +
  scale_fill_viridis_d(option = "magma")

# Transformando em gráfico interativo
print(ggplotly(grafico_raca))

# (O Gráfico de Votos foi desativado temporariamente pois a base de Votação Nacional é pesada demais para o R extrair de uma vez só)

message("✅ Script executado! Confira a aba 'Viewer' no seu RStudio para ver as Tabelas e Gráficos Interativos.")
