# ==============================================================================
# VISUALIZAÇÃO 05: TOP 30 DEPUTADOS FEDERAIS MAIS CAROS DO BRASIL
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(plotly)

# 1. Carregar Datamart Ouro
datamart <- read_parquet("tse/data/03_gold/parquet/datamart_candidatos_2022.parquet")

# 2. Top 30 Maiores Gastos do Brasil (Dep. Federal)
top_milionarios <- datamart %>%
  filter(str_detect(DS_CARGO, "DEPUTADO FEDERAL")) %>%
  arrange(desc(Total_Gasto)) %>%
  head(30) %>%
  # Criar label limpo combinando Nome e Partido
  mutate(
    Nome_Exibicao = paste0(NM_URNA_CANDIDATO, " (", SG_PARTIDO, "-", SG_UF, ")"),
    Nome_Exibicao = reorder(Nome_Exibicao, Total_Gasto)
  )

# 3. Plotagem com Facet
g5 <- ggplot(top_milionarios, aes(x = Total_Gasto, y = Nome_Exibicao, fill = Status_Eleicao,
                                  text = paste("Candidato:", NM_URNA_CANDIDATO,
                                               "<br>Partido/Estado:", paste(SG_PARTIDO, SG_UF, sep="-"),
                                               "<br>Total Gasto:", scales::dollar(Total_Gasto, prefix="R$"),
                                               "<br>Total Votos:", Total_Votos,
                                               "<br>Situação:", Status_Eleicao))) +
  geom_col(alpha = 0.9) +
  scale_fill_manual(values = c("Eleito" = "#27ae60", "Não Eleito" = "#c0392b")) +
  scale_x_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale(), prefix="R$ ")) +
  facet_wrap(~Status_Eleicao, scales = "free_y") +
  labs(
    title = "Os 30 Deputados que Mais Gastaram no Brasil",
    subtitle = "Sucesso x Fracasso das Campanhas Milionárias",
    x = "Total Gasto na Campanha (R$)",
    y = "",
    fill = "Status Final"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 12)
  )

# 4. Exibir no RStudio (Viewer)
p5 <- ggplotly(g5, tooltip = "text")
print(p5)
