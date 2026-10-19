# ==============================================================================
# VISUALIZAÇÃO 03: DISPERSÃO GEOGRÁFICA (VOTOS CONCENTRADOS VS DIFUSOS)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(plotly)

# 1. Carregar Datamart Ouro
datamart <- read_parquet("tse/data/03_gold/parquet/datamart_candidatos_2022.parquet")

# 2. Preparar Dados: Analisar a Correlação entre Votos e Nº de Municípios
dispersao_df <- datamart %>%
  filter(str_detect(DS_CARGO, "DEPUTADO FEDERAL")) %>%
  filter(Total_Votos > 1000) %>% # Filtrar apenas candidatos viáveis/relevantes
  mutate(
    Votos_Por_Municipio = Total_Votos / Qtd_Municipios_Com_Voto,
    Estrategia = ifelse(Qtd_Municipios_Com_Voto > 100, "Voto Pulverizado (Estado todo)", "Voto Concentrado (Curral Eleitoral)")
  )

# 3. Plotagem do Gráfico de Dispersão
g3 <- ggplot(dispersao_df, aes(x = Qtd_Municipios_Com_Voto, y = Total_Votos, color = Status_Eleicao,
                               text = paste("Candidato:", NM_URNA_CANDIDATO,
                                            "<br>Partido:", SG_PARTIDO,
                                            "<br>Municípios c/ Voto:", Qtd_Municipios_Com_Voto,
                                            "<br>Total Votos:", Total_Votos,
                                            "<br>Gasto:", scales::dollar(Total_Gasto, prefix="R$")))) +
  geom_point(alpha = 0.6) +
  scale_y_log10(labels = scales::comma_format(big.mark = ".", decimal.mark = ",")) +
  scale_color_manual(values = c("Eleito" = "#27ae60", "Não Eleito" = "#c0392b")) +
  geom_vline(xintercept = median(dispersao_df$Qtd_Municipios_Com_Voto), linetype = "dotted") +
  labs(
    title = "Estratégia Geográfica: Currais Eleitorais vs Pulverização",
    subtitle = "Deputados Federais (Min. 1000 votos) - Votos Totais vs Qtd de Municípios atingidos",
    x = "Quantidade de Municípios onde recebeu Voto",
    y = "Total de Votos (Escala Logarítmica)",
    color = "Status"
  ) +
  theme_minimal()

# 4. Exibir no RStudio (Viewer)
p3 <- ggplotly(g3, tooltip = "text")
print(p3)
