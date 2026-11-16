# ==============================================================================
# GOLD 02: DATAMART MUNICIPAL 2024 (MG & SP) -> 100% PARQUET
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

dir_create("03_gold/data")
message("=== [Gold] Construindo Datamart Municipal 2024 ===")

candidatos_dm <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet")

totais_municipio <- candidatos_dm %>%
  group_by(SG_UF, CD_MUNICIPIO, NM_MUNICIPIO) %>%
  summarise(
    Total_Candidatos = n(),
    Pct_Cand_Mulheres = mean(DS_GENERO == "FEMININO", na.rm = TRUE) * 100,
    Pct_Cand_Negros_Indigenas = mean(DS_COR_RACA %in% c("PRETA", "PARDA", "INDÍGENA"), na.rm = TRUE) * 100,
    Total_Votos_Nominais = sum(Total_Votos, na.rm = TRUE),
    Total_Gasto_Campanhas = sum(Total_Gasto, na.rm = TRUE),
    Total_Arrecadado_Campanhas = sum(Total_Arrecadado, na.rm = TRUE),
    Total_Fundo_Publico_Municipio = sum(Total_Fundo_Publico, na.rm = TRUE),
    .groups = "drop"
  )

prefeitos_eleitos <- candidatos_dm %>%
  filter(CD_CARGO == "11", Status_Eleicao == "Eleito") %>%
  select(
    SG_UF, CD_MUNICIPIO,
    Prefeito_Eleito_Nome = NM_URNA_CANDIDATO,
    Prefeito_Eleito_Partido = SG_PARTIDO,
    Prefeito_Eleito_Genero = DS_GENERO,
    Prefeito_Eleito_Raca = DS_COR_RACA,
    Prefeito_Eleito_Instrucao = DS_GRAU_INSTRUCAO,
    Prefeito_Eleito_Votos = Total_Votos,
    Prefeito_Eleito_Gasto = Total_Gasto
  ) %>%
  distinct(CD_MUNICIPIO, .keep_all = TRUE)

datamart_municipal <- totais_municipio %>%
  left_join(prefeitos_eleitos, by = c("SG_UF", "CD_MUNICIPIO")) %>%
  mutate(
    Custo_Medio_Voto_Municipio = ifelse(Total_Votos_Nominais > 0, Total_Gasto_Campanhas / Total_Votos_Nominais, NA_real_),
    Pct_Fundo_Publico_Municipio = ifelse(Total_Arrecadado_Campanhas > 0, Total_Fundo_Publico_Municipio / Total_Arrecadado_Campanhas, 0)
  )

write_parquet(datamart_municipal, "03_gold/data/datamart_municipal_2024.parquet", compression = "zstd")
message("✔ datamart_municipal_2024.parquet salvo (", nrow(datamart_municipal), " municípios)")
