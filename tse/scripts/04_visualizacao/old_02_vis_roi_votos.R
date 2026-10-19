# ==============================================================================
# SCRIPT 02 (VIS): O ROI - CUSTO DO VOTO (DINHEIRO VS VOTOS)
# ==============================================================================
# IMPORTANTE: Este script apenas lê os dados já limpos e agregados em processed/
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(plotly)

message("Carregando Dados Processados...")

candidatos <- read_parquet("tse/data/02_silver/parquet/candidatos_clean.parquet")
votos_totais <- read_parquet("tse/data/02_silver/parquet/votos_agregados.parquet")
despesas <- read_parquet("tse/data/02_silver/parquet/despesas_totais.parquet")

# O GRANDE JOIN ANALÍTICO
roi_voto <- candidatos %>%
  inner_join(despesas, by = "SQ_CANDIDATO") %>%
  inner_join(votos_totais, by = "SQ_CANDIDATO") %>%
  filter(Total_Votos > 1000) %>% # Filtra candidatos nanicos/desistentes
  mutate(Custo_Por_Voto = Despesa_Total_Geral / Total_Votos) %>%
  arrange(desc(Custo_Por_Voto))

# ----------------- Gráfico de Dispersão -----------------
# Custo vs Votos (Apenas para Deputado Federal de SP para exemplificar o poder da análise)
dados_grafico <- roi_voto %>%
  filter(DS_CARGO == "DEPUTADO FEDERAL", SG_UF == "SP") %>%
  mutate(Hover = paste(NM_URNA_CANDIDATO, "-", SG_PARTIDO, "<br>Custo/Voto: R$", round(Custo_Por_Voto,2)))

grafico_roi <- ggplot(dados_grafico, aes(x = Total_Votos, y = Despesa_Total_Geral, color = Status_Eleicao, text = Hover)) +
  geom_point(alpha = 0.6) +
  scale_y_log10(labels = scales::dollar_format(prefix = "R$ ")) +
  scale_x_log10() +
  scale_color_manual(values = c("Eleito" = "#2ecc71", "Não Eleito" = "#e74c3c")) +
  theme_minimal() +
  labs(title = "Eficiência Eleitoral: Votos Obtidos vs Dinheiro Gasto (SP)",
       subtitle = "Escala Logarítmica (Passe o mouse para ver detalhes)",
       x = "Total de Votos (Escala Log)", y = "Total Gasto (Escala Log)")

print(ggplotly(grafico_roi, tooltip = "text"))
