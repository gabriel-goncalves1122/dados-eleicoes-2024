# ==============================================================================
# VISUALIZA��O 06: EXTREMOS DO CUSTO POR VOTO (ELEI��ES 2024 - MG & SP)
# ==============================================================================
# Compara os candidatos a Prefeito eleitos com maior e menor custo unit�rio por voto.

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

# 2. Filtrar Prefeitos Eleitos
eleitos <- datamart %>%
  filter(CD_CARGO == "11", Status_Eleicao == "Eleito") %>%
  filter(Total_Votos > 2000, Total_Gasto > 5000, !is.na(Custo_Por_Voto))

# 3. Separar Top 15 Mais Caros e Top 15 Mais Baratos
mais_caros <- eleitos %>% arrange(desc(Custo_Por_Voto)) %>% head(15) %>% mutate(Categoria = "Custo Mais Alto por Voto")
mais_baratos <- eleitos %>% arrange(Custo_Por_Voto) %>% head(15) %>% mutate(Categoria = "Custo Mais Eficiente (Baixo)")

extremos <- bind_rows(mais_caros, mais_baratos) %>%
  mutate(
    Nome_Exibicao = paste0(NM_URNA_CANDIDATO, " (", SG_PARTIDO, " - ", NM_UE, ")"),
    Nome_Exibicao = tidytext::reorder_within(Nome_Exibicao, Custo_Por_Voto, Categoria)
  )

# 4. Plotagem
g6 <- ggplot(extremos, aes(
  x = Custo_Por_Voto, y = Nome_Exibicao, fill = Categoria,
  text = paste(
    "Prefeito:", NM_URNA_CANDIDATO,
    "<br>Munic�pio:", NM_UE, "-", SG_UF,
    "<br>Partido:", SG_PARTIDO,
    "<br>Custo por Voto: R$ ", round(Custo_Por_Voto, 2),
    "<br>Total Votos:", Total_Votos,
    "<br>Total Gasto:", scales::dollar(Total_Gasto, prefix = "R$ ")
  )
)) +
  geom_col(alpha = 0.9) +
  scale_fill_manual(values = c("Custo Mais Alto por Voto" = "#c0392b", "Custo Mais Eficiente (Baixo)" = "#2980b9")) +
  tidytext::scale_y_reordered() +
  scale_x_continuous(labels = scales::dollar_format(prefix = "R$ ")) +
  facet_wrap(~Categoria, scales = "free") +
  labs(
    title = "Extremos da Efici�ncia Financeira Eleitoral (Prefeitos Eleitos 2024 - MG & SP)",
    subtitle = "Quanto custou cada voto recebido pelos prefeitos vencedores?",
    x = "Custo por Voto (R$ / Voto)",
    y = ""
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 11)
  )

# 5. Exibir no RStudio (Viewer)
p6 <- ggplotly(g6, tooltip = "text")
print(p6)
