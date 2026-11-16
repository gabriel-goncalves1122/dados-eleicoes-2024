# ==============================================================================
# GOLD 02: DATAMART MUNICIPAL 2024 (MG & SP) -> 100% PARQUET (snake_case)
# ==============================================================================
# Consolida finanças, votos, prefeito eleito e métricas de representatividade
# (candidaturas vs. eleitos por gênero e cor/raça) por município.

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
  group_by(sg_uf, cd_municipio_tse, nm_municipio) %>%
  summarise(
    total_candidatos = as.integer(n()),
    total_eleitos = as.integer(sum(is_eleito, na.rm = TRUE)),
    # Representatividade nas Candidaturas (%)
    pct_cand_mulheres = mean(ds_genero == "FEMININO", na.rm = TRUE) * 100,
    pct_cand_branca = mean(ds_cor_raca == "BRANCA", na.rm = TRUE) * 100,
    pct_cand_preta = mean(ds_cor_raca == "PRETA", na.rm = TRUE) * 100,
    pct_cand_parda = mean(ds_cor_raca == "PARDA", na.rm = TRUE) * 100,
    pct_cand_indigena = mean(ds_cor_raca == "INDÍGENA", na.rm = TRUE) * 100,
    pct_cand_negros_indigenas = mean(ds_cor_raca %in% c("PRETA", "PARDA", "INDÍGENA"), na.rm = TRUE) * 100,
    # Representatividade entre Eleitos (%)
    pct_eleitos_mulheres = ifelse(
      sum(is_eleito, na.rm = TRUE) > 0,
      mean(ds_genero[is_eleito] == "FEMININO", na.rm = TRUE) * 100,
      NA_real_
    ),
    pct_eleitos_branca = ifelse(
      sum(is_eleito, na.rm = TRUE) > 0,
      mean(ds_cor_raca[is_eleito] == "BRANCA", na.rm = TRUE) * 100,
      NA_real_
    ),
    pct_eleitos_preta = ifelse(
      sum(is_eleito, na.rm = TRUE) > 0,
      mean(ds_cor_raca[is_eleito] == "PRETA", na.rm = TRUE) * 100,
      NA_real_
    ),
    pct_eleitos_parda = ifelse(
      sum(is_eleito, na.rm = TRUE) > 0,
      mean(ds_cor_raca[is_eleito] == "PARDA", na.rm = TRUE) * 100,
      NA_real_
    ),
    pct_eleitos_indigena = ifelse(
      sum(is_eleito, na.rm = TRUE) > 0,
      mean(ds_cor_raca[is_eleito] == "INDÍGENA", na.rm = TRUE) * 100,
      NA_real_
    ),
    pct_eleitos_negros_indigenas = ifelse(
      sum(is_eleito, na.rm = TRUE) > 0,
      mean(ds_cor_raca[is_eleito] %in% c("PRETA", "PARDA", "INDÍGENA"), na.rm = TRUE) * 100,
      NA_real_
    ),
    # Votos e Finanças Municipais
    total_votos_nominais = sum(total_votos, na.rm = TRUE),
    total_gasto_campanhas = sum(total_gasto, na.rm = TRUE),
    total_arrecadado_campanhas = sum(total_arrecadado, na.rm = TRUE),
    total_fundo_publico_municipio = sum(total_fundo_publico, na.rm = TRUE),
    .groups = "drop"
  )

prefeitos_eleitos <- candidatos_dm %>%
  filter(cd_cargo == 11L, is_eleito) %>%
  select(
    sg_uf, cd_municipio_tse,
    prefeito_eleito_nome = nm_urna_candidato,
    prefeito_eleito_partido = sg_partido,
    prefeito_eleito_genero = ds_genero,
    prefeito_eleito_raca = ds_cor_raca,
    prefeito_eleito_instrucao = ds_grau_instrucao,
    prefeito_eleito_votos = total_votos,
    prefeito_eleito_gasto = total_gasto
  ) %>%
  distinct(cd_municipio_tse, .keep_all = TRUE)

datamart_municipal <- totais_municipio %>%
  left_join(prefeitos_eleitos, by = c("sg_uf", "cd_municipio_tse")) %>%
  mutate(
    custo_medio_voto_municipio = ifelse(total_votos_nominais > 0, total_gasto_campanhas / total_votos_nominais, NA_real_),
    pct_fundo_publico_municipio = ifelse(total_arrecadado_campanhas > 0, (total_fundo_publico_municipio / total_arrecadado_campanhas) * 100, 0)
  )

write_parquet(datamart_municipal, "03_gold/data/datamart_municipal_2024.parquet", compression = "zstd")
message("✔ datamart_municipal_2024.parquet salvo (", nrow(datamart_municipal), " municípios, ", ncol(datamart_municipal), " colunas)")
