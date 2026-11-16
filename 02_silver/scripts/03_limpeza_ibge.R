# ==============================================================================
# SILVER 03: CONSOLIDAÇÃO IBGE & DE-PARA COM TIPAGEM FORTE (100% PARQUET)
# ==============================================================================
# Padroniza em snake_case, converte PIB de Mil Reais para Reais reais, trata
# sentinelas '-' como 0.0 em indicadores de ausência e tipa chaves/percentuais.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

dir_create("02_silver/data/ibge")
message("=== [Silver] Consolidando IBGE (Censo 2022 + PIB) e De-Para ===")

to_num <- function(x, zero_se_hifen = FALSE) {
  x_str <- str_squish(as.character(x))
  if (zero_se_hifen) {
    x_str <- if_else(x_str == "-", "0", x_str)
  }
  suppressWarnings(as.numeric(x_str))
}

# 1. Padronização da tabela De-Para (MG & SP)
depara_clean <- read_parquet("01_bronze/data/depara_tse_ibge.parquet") %>%
  transmute(
    cd_municipio_tse = str_pad(as.character(codigo_tse), 5, "left", "0"),
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    cd_municipio_ibge_6 = str_pad(as.character(codigo_ibge_6), 6, "left", "0"),
    sg_uf = str_to_upper(uf),
    nm_municipio_tse = str_to_upper(str_squish(nome_municipio_tse)),
    is_capital = as.character(capital) == "1"
  )

write_parquet(depara_clean, "02_silver/data/depara_tse_ibge.parquet", compression = "zstd")
message("✔ depara_tse_ibge.parquet salvo (", nrow(depara_clean), " municípios)")

# 2. Consolidação dos indicadores municipais IBGE
pop <- read_parquet("01_bronze/data/ibge/populacao_2022.parquet") %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    nm_municipio_ibge = str_squish(nome_municipio),
    populacao_2022 = as.integer(to_num(populacao))
  )

pib <- read_parquet("01_bronze/data/ibge/pib_municipal.parquet") %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pib_reais_2023 = to_num(pib) * 1000
  )

pib_set <- read_parquet("01_bronze/data/ibge/pib_composicao_setorial.parquet") %>%
  mutate(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    val = to_num(valor_mil_reais) * 1000
  ) %>%
  select(cd_municipio_ibge, codigo_variavel, val) %>%
  pivot_wider(names_from = codigo_variavel, values_from = val, names_prefix = "v_") %>%
  transmute(
    cd_municipio_ibge,
    vab_adm_publica_reais_2021 = v_525,
    vab_total_reais_2021 = v_37 - v_513,
    pct_adm_publica_vab_2021 = if_else(vab_total_reais_2021 > 0, (v_525 / vab_total_reais_2021) * 100, NA_real_),
    pct_impostos_pib_2021 = if_else(v_37 > 0, (v_513 / v_37) * 100, NA_real_)
  )

alfa <- read_parquet("01_bronze/data/ibge/censo2022_taxa_alfabetizacao.parquet") %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    taxa_alfabetizacao_15mais = to_num(taxa_alfabetizacao)
  )

urb <- read_parquet("01_bronze/data/ibge/censo2022_urbana_rural.parquet") %>%
  filter(codigo_variavel == "1000093", situacao_domicilio == "Urbana") %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pct_populacao_urbana = to_num(valor, zero_se_hifen = TRUE)
  )

agua <- read_parquet("01_bronze/data/ibge/censo2022_abastecimento_agua.parquet") %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pct_agua_rede_geral = to_num(pct_rede_geral, zero_se_hifen = TRUE)
  )

esgoto <- read_parquet("01_bronze/data/ibge/censo2022_esgotamento_sanitario.parquet") %>%
  mutate(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pct = to_num(pct_domicilios, zero_se_hifen = TRUE),
    chave = if_else(str_detect(tipo_esgotamento, "Rede geral"), "pct_esgoto_adequado", "pct_sem_banheiro")
  ) %>%
  select(cd_municipio_ibge, chave, pct) %>%
  pivot_wider(names_from = chave, values_from = pct)

raca <- read_parquet("01_bronze/data/ibge/censo2022_cor_raca.parquet") %>%
  mutate(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pop = to_num(populacao, zero_se_hifen = TRUE)
  ) %>%
  group_by(cd_municipio_ibge) %>%
  summarise(
    tot = sum(pop[cor_raca == "Total"], na.rm = TRUE),
    pct_branca_censo = if_else(tot > 0, sum(pop[cor_raca == "Branca"], na.rm = TRUE) / tot * 100, NA_real_),
    pct_preta_censo = if_else(tot > 0, sum(pop[cor_raca == "Preta"], na.rm = TRUE) / tot * 100, NA_real_),
    pct_parda_censo = if_else(tot > 0, sum(pop[cor_raca == "Parda"], na.rm = TRUE) / tot * 100, NA_real_),
    pct_indigena_censo = if_else(tot > 0, sum(pop[cor_raca == "Indígena"], na.rm = TRUE) / tot * 100, NA_real_),
    pct_negros_indigenas_censo = if_else(
      tot > 0,
      sum(pop[cor_raca %in% c("Preta", "Parda", "Indígena")], na.rm = TRUE) / tot * 100,
      NA_real_
    ),
    .groups = "drop"
  ) %>%
  select(-tot)

sexo <- read_parquet("01_bronze/data/ibge/censo2022_sexo.parquet") %>%
  mutate(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pop = to_num(populacao, zero_se_hifen = TRUE)
  ) %>%
  group_by(cd_municipio_ibge) %>%
  summarise(
    tot = sum(pop, na.rm = TRUE),
    pct_mulheres_censo = if_else(tot > 0, sum(pop[sexo == "Mulheres"], na.rm = TRUE) / tot * 100, NA_real_),
    .groups = "drop"
  ) %>%
  select(-tot)

ibge_indicadores <- pop %>%
  inner_join(pib, by = "cd_municipio_ibge") %>%
  left_join(pib_set, by = "cd_municipio_ibge") %>%
  left_join(alfa, by = "cd_municipio_ibge") %>%
  left_join(urb, by = "cd_municipio_ibge") %>%
  left_join(agua, by = "cd_municipio_ibge") %>%
  left_join(esgoto, by = "cd_municipio_ibge") %>%
  left_join(raca, by = "cd_municipio_ibge") %>%
  left_join(sexo, by = "cd_municipio_ibge") %>%
  mutate(
    pib_per_capita_reais = if_else(populacao_2022 > 0, pib_reais_2023 / populacao_2022, NA_real_)
  ) %>%
  arrange(desc(pib_per_capita_reais))

write_parquet(ibge_indicadores, "02_silver/data/ibge/ibge_indicadores.parquet", compression = "zstd")
message("✔ ibge_indicadores.parquet salvo (", nrow(ibge_indicadores), " municípios, ", ncol(ibge_indicadores), " colunas)")
