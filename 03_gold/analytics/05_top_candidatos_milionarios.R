# ==============================================================================
# VISUALIZA��O 05: TOP 30 CAMPANHAS MAIS CARAS (ELEI��ES 2024 - MG & SP)
# ==============================================================================
# As maiores despesas contratadas para Prefeito e a taxa de sucesso nas urnas.

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

# 2. Top 30 Maiores Gastos para Prefeito
top_milionarios <- datamart %>%
  filter(CD_CARGO == "11") %>% # Prefeito
  arrange(desc(Total_Gasto)) %>%
  head(30) %>%
  mutate(
    Nome_Exibicao = paste0(NM_URNA_CANDIDATO, " (", SG_PARTIDO, " - ", NM_UE, ")"),
    Nome_Exibicao = reorder(Nome_Exibicao, Total_Gasto)
  )

# 3. Plotagem
g5 <- ggplot(top_milionarios, aes(
  x = Total_Gasto, y = Nome_Exibicao, fill = Status_Eleicao,
  text = paste(
    "Candidato:", NM_URNA_CANDIDATO,
    "<br>Munic�pio:", NM_UE, "-", SG_UF,
    "<br>Partido:", SG_PARTIDO,
    "<br>Total Gasto:", scales::dollar(Total_Gasto, prefix = "R$ "),
    "<br>Total Votos:", Total_Votos,
    "<br>Situa��o:", Status_Eleicao
  )
)) +
  geom_col(alpha = 0.9) +
  scale_fill_manual(values = c("Eleito" = "#27ae60", "2� Turno" = "#f39c12", "N�o Eleito" = "#c0392b")) +
  scale_x_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale(), prefix = "R$ ")) +
  facet_wrap(~Status_Eleicao, scales = "free_y") +
  labs(
    title = "As 30 Campanhas para Prefeito que Mais Gastaram (2024 - MG & SP)",
    subtitle = "Sucesso x Fracasso das Campanhas com Maior Or�amento Financeiro",
    x = "Total Gasto na Campanha (R$)",
    y = "",
    fill = "Situa��o"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 11)
  )

# 4. Exibir no RStudio (Viewer)
p5 <- ggplotly(g5, tooltip = "text")
print(p5)
