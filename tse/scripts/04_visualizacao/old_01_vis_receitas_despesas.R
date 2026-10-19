# ==============================================================================
# SCRIPT 01 (VIS): ANÁLISE GRÁFICA DE RECEITAS E DESPESAS
# ==============================================================================
# IMPORTANTE: Este script NÃO processa dados. Ele apenas consome a pasta processed.
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(plotly)
library(reactable)

message("Carregando Dados Processados...")

candidatos <- read_parquet("tse/data/02_silver/parquet/candidatos_clean.parquet")
receitas <- read_parquet("tse/data/02_silver/parquet/receitas_agregadas.parquet")

# 1. Gráfico das Campanhas mais ricas
top_ricos <- receitas %>%
  head(20) %>%
  inner_join(candidatos %>% select(SQ_CANDIDATO, NM_URNA_CANDIDATO), by = "SQ_CANDIDATO") %>%
  mutate(NM_URNA_CANDIDATO = fct_reorder(NM_URNA_CANDIDATO, Total_Geral)) %>%
  pivot_longer(cols = c(`Dinheiro Público`, `Dinheiro Privado/Doações`), names_to = "Origem", values_to = "Valor")

grafico_receitas <- ggplot(top_ricos, aes(x = Valor, y = NM_URNA_CANDIDATO, fill = Origem)) +
  geom_col() +
  scale_x_continuous(labels = scales::dollar_format(prefix = "R$ ")) +
  theme_minimal() +
  labs(title = "Top 20 Campanhas Mais Ricas (2022)", x = "Receita", y = "")

print(ggplotly(grafico_receitas))

# 2. Tabela de Onde o Dinheiro foi Gasto no Brasil (Global)
ranking_gastos <- despesas_cat %>%
  group_by(DS_ORIGEM_DESPESA) %>%
  summarise(Soma_Gasta = sum(Total_Gasto)) %>%
  arrange(desc(Soma_Gasta)) %>%
  head(20)

print(reactable(ranking_gastos, 
                columns = list(Soma_Gasta = colDef(format = colFormat(currency = "BRL"))),
                searchable = TRUE))
