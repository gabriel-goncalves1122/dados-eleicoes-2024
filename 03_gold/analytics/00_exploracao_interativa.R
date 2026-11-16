# ==============================================================================
# ANALYTICS 00: EXPLORAÇÃO INTERATIVA (TSE 2024 + IBGE CENSO 2022)
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")
library(reactable)

candidatos <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet")
integrado <- read_parquet("03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet")

# Tabela 1: Candidatos por Partido e Gênero
tabela_genero_partido <- candidatos %>%
  filter(!is.na(ds_genero)) %>%
  count(sg_partido, ds_genero) %>%
  pivot_wider(names_from = ds_genero, values_from = n, values_fill = 0) %>%
  mutate(total_geral = rowSums(across(where(is.numeric)))) %>%
  arrange(desc(total_geral))

print(reactable(tabela_genero_partido, searchable = TRUE, striped = TRUE, highlight = TRUE, defaultPageSize = 10))

# Tabela 2: Municípios integrados (Representatividade + Socioeconomia)
tabela_municipios <- integrado %>%
  select(
    sg_uf, nm_municipio, populacao_2022, pib_per_capita_reais,
    pct_adm_publica_vab_2021, pct_mulheres_censo, pct_eleitos_mulheres,
    gap_eleitos_mulheres, pct_negros_indigenas_censo, pct_eleitos_negros_indigenas,
    gap_eleitos_negros_indigenas
  ) %>%
  arrange(desc(populacao_2022))

print(reactable(tabela_municipios %>% head(150), searchable = TRUE, striped = TRUE))

# Gráfico Exploratório: Distribuição de Raça/Cor dos Candidatos (2024)
g0 <- candidatos %>%
  filter(!is.na(ds_cor_raca)) %>%
  count(ds_cor_raca) %>%
  mutate(ds_cor_raca = fct_reorder(ds_cor_raca, n)) %>%
  ggplot(aes(x = n, y = ds_cor_raca, fill = ds_cor_raca,
             text = paste("Cor/Raça:", ds_cor_raca, "<br>Candidatos:", format(n, big.mark = ".")))) +
  geom_col(show.legend = FALSE) +
  scale_x_continuous(labels = label_number(big.mark = ".")) +
  scale_fill_viridis_d(option = "magma") +
  labs(
    title = "Distribuição de Cor/Raça dos Candidatos (Eleições 2024 - MG & SP)",
    x = "Número de Candidatos", y = NULL
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g0, "00_exploracao_raca_candidatos.html")
