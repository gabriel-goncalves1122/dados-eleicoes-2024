# ==============================================================================
# VISUALIZAÇÃO 06: OS EXTREMOS DO CUSTO POR VOTO (APENAS ELEITOS)
# ==============================================================================
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(arrow)
library(plotly)

# 1. Carregar Datamart Ouro
datamart <- read_parquet("tse/data/03_gold/parquet/datamart_candidatos_2022.parquet")

# 2. Filtrar apenas ELEITOS viáveis
eleitos <- datamart %>%
  filter(str_detect(DS_CARGO, "DEPUTADO FEDERAL")) %>%
  filter(Status_Eleicao == "Eleito") %>%
  filter(Total_Votos > 10000) # Evitar ruídos estatísticos

# 3. Separar Top 15 Mais Caros e Top 15 Mais Baratos
mais_caros <- eleitos %>% arrange(desc(Custo_Por_Voto)) %>% head(15) %>% mutate(Categoria = "O Voto Mais Caro")
mais_baratos <- eleitos %>% arrange(Custo_Por_Voto) %>% head(15) %>% mutate(Categoria = "O Voto Mais Barato")

extremos <- bind_rows(mais_caros, mais_baratos) %>%
  mutate(
    Nome_Exibicao = paste0(NM_URNA_CANDIDATO, " (", SG_PARTIDO, "-", SG_UF, ")"),
    # Reordenar para o gráfico
    Nome_Exibicao = tidytext::reorder_within(Nome_Exibicao, Custo_Por_Voto, Categoria)
  )

# 4. Plotagem
g6 <- ggplot(extremos, aes(x = Custo_Por_Voto, y = Nome_Exibicao, fill = Categoria,
                           text = paste("Candidato:", NM_URNA_CANDIDATO,
                                        "<br>Custo por Voto:", scales::dollar(Custo_Por_Voto, prefix="R$"),
                                        "<br>Total Votos:", Total_Votos,
                                        "<br>Total Gasto:", scales::dollar(Total_Gasto, prefix="R$")))) +
  geom_col(alpha = 0.9) +
  scale_fill_manual(values = c("O Voto Mais Caro" = "#c0392b", "O Voto Mais Barato" = "#2980b9")) +
  tidytext::scale_y_reordered() +
  scale_x_continuous(labels = scales::dollar_format(prefix = "R$")) +
  facet_wrap(~Categoria, scales = "free") +
  labs(
    title = "Extremos da Eficiência Eleitoral (Apenas Deputados Eleitos)",
    subtitle = "Quanto custou cada voto dos candidatos que ganharam a eleição?",
    x = "Custo por Voto (R$/Voto)",
    y = ""
  ) +
  theme_minimal() +
  theme(legend.position = "none", strip.text = element_text(face = "bold", size = 12))

# 5. Exibir no RStudio (Viewer)
p6 <- ggplotly(g6, tooltip = "text")
print(p6)
