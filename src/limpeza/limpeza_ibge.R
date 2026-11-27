# ==============================================================================
# LIMPEZA PRATA 01: DIMENSÃO MUNICÍPIO E FATO INDICADORES IBGE (CONSTELAÇÃO)
# ==============================================================================
# Gera em dados/prata/:
#   - dim_municipio.parquet            (5.570 municípios com UF, região e porte)
#   - fato_indicadores_municipio.parquet (indicadores numéricos Censo 2022 + PIB)

if (file.exists("src/config.R")) source("src/config.R") else source("../../src/config.R")

library(tidyverse)
library(arrow)
library(fs)

dir_create(DADOS_PRATA)
message("=== [Prata] Construindo dim_municipio e fato_indicadores_municipio (Brasil) ===")

to_num <- function(x, zero_se_hifen = FALSE) {
  x_str <- str_squish(as.character(x))
  if (zero_se_hifen) x_str <- if_else(x_str == "-", "0", x_str)
  suppressWarnings(as.numeric(x_str))
}

uf_para_regiao <- function(uf) {
  case_when(
    uf %in% c("AC", "AP", "AM", "PA", "RO", "RR", "TO") ~ "Norte",
    uf %in% c("AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE") ~ "Nordeste",
    uf %in% c("DF", "GO", "MT", "MS") ~ "Centro-Oeste",
    uf %in% c("ES", "MG", "RJ", "SP") ~ "Sudeste",
    uf %in% c("PR", "RS", "SC") ~ "Sul",
    TRUE ~ NA_character_
  )
}

pasta_ibge_bronze <- path(DADOS_BRONZE, "ibge")

depara <- read_parquet(path(DADOS_BRONZE, "depara_tse_ibge.parquet")) %>%
  transmute(
    cd_municipio_tse = str_pad(as.character(codigo_tse), 5, "left", "0"),
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    sg_uf = str_to_upper(uf),
    nm_municipio_tse = str_to_upper(str_squish(nome_municipio_tse)),
    is_capital = as.character(capital) == "1"
  ) %>%
  distinct(cd_municipio_ibge, .keep_all = TRUE)

pop <- read_parquet(path(pasta_ibge_bronze, "populacao_2022.parquet")) %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    nm_municipio_ibge = str_squish(nome_municipio),
    populacao_2022 = as.integer(to_num(populacao))
  ) %>%
  distinct(cd_municipio_ibge, .keep_all = TRUE)

dim_municipio <- depara %>%
  left_join(pop, by = "cd_municipio_ibge") %>%
  transmute(
    cd_municipio_ibge,
    cd_municipio_tse,
    sg_uf,
    regiao = uf_para_regiao(sg_uf),
    nm_municipio = coalesce(nm_municipio_ibge, nm_municipio_tse),
    porte_municipio = case_when(
      is.na(populacao_2022) ~ NA_character_,
      populacao_2022 < 20000 ~ "Pequeno Porte I (<20k)",
      populacao_2022 < 50000 ~ "Pequeno Porte II (20k-50k)",
      populacao_2022 < 100000 ~ "Médio Porte (50k-100k)",
      populacao_2022 < 500000 ~ "Grande Porte (100k-500k)",
      TRUE ~ "Metrópole (>500k)"
    ),
    is_capital,
    tem_eleicao_municipal = sg_uf != "DF"
  )

# Garante cobertura de municípios emancipados presentes no TSE 2024 mas ausentes no De-Para/Censo 2022
# (ex.: Boa Esperança do Norte - MT, código TSE 73709)
arq_cand_bronze <- path(DADOS_BRONZE, "tse", "candidatos.parquet")
if (file_exists(arq_cand_bronze)) {
  tse_muns <- open_dataset(arq_cand_bronze) %>%
    distinct(SG_UE, NM_UE, SG_UF) %>%
    collect() %>%
    transmute(
      cd_municipio_tse = str_pad(as.character(SG_UE), 5, "left", "0"),
      nm_municipio = str_to_upper(str_squish(NM_UE)),
      sg_uf = str_to_upper(str_squish(SG_UF))
    ) %>%
    anti_join(dim_municipio, by = "cd_municipio_tse") %>%
    transmute(
      cd_municipio_ibge = NA_character_,
      cd_municipio_tse,
      sg_uf,
      regiao = uf_para_regiao(sg_uf),
      nm_municipio,
      porte_municipio = "Pequeno Porte I (<20k)",
      is_capital = FALSE,
      tem_eleicao_municipal = TRUE
    )
  if (nrow(tse_muns) > 0) {
    dim_municipio <- bind_rows(dim_municipio, tse_muns)
  }
}

write_parquet(dim_municipio, path(DADOS_PRATA, "dim_municipio.parquet"), compression = "zstd")
message("✔ dados/prata/dim_municipio.parquet salvo (", nrow(dim_municipio), " municípios, ", n_distinct(dim_municipio$sg_uf), " UFs)")

pib <- read_parquet(path(pasta_ibge_bronze, "pib_municipal.parquet")) %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pib_reais_2023 = to_num(pib) * 1000
  ) %>%
  distinct(cd_municipio_ibge, .keep_all = TRUE)

pib_set <- read_parquet(path(pasta_ibge_bronze, "pib_composicao_setorial.parquet")) %>%
  mutate(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    val = to_num(valor_mil_reais) * 1000
  ) %>%
  select(cd_municipio_ibge, codigo_variavel, val) %>%
  pivot_wider(names_from = codigo_variavel, values_from = val, names_prefix = "v_", values_fn = first) %>%
  transmute(
    cd_municipio_ibge,
    vab_adm_publica_reais_2021 = v_525,
    vab_total_reais_2021 = v_37 - v_513,
    pct_adm_publica_vab_2021 = if_else(vab_total_reais_2021 > 0, (v_525 / vab_total_reais_2021) * 100, NA_real_),
    pct_impostos_pib_2021 = if_else(v_37 > 0, (v_513 / v_37) * 100, NA_real_)
  )

alfa <- read_parquet(path(pasta_ibge_bronze, "censo2022_taxa_alfabetizacao.parquet")) %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    taxa_alfabetizacao_15mais = to_num(taxa_alfabetizacao)
  ) %>%
  distinct(cd_municipio_ibge, .keep_all = TRUE)

urb <- read_parquet(path(pasta_ibge_bronze, "censo2022_urbana_rural.parquet")) %>%
  filter(codigo_variavel == "1000093", situacao_domicilio == "Urbana") %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pct_populacao_urbana = to_num(valor, zero_se_hifen = TRUE)
  ) %>%
  distinct(cd_municipio_ibge, .keep_all = TRUE)

agua <- read_parquet(path(pasta_ibge_bronze, "censo2022_abastecimento_agua.parquet")) %>%
  transmute(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pct_agua_rede_geral = to_num(pct_rede_geral, zero_se_hifen = TRUE)
  ) %>%
  distinct(cd_municipio_ibge, .keep_all = TRUE)

esgoto <- read_parquet(path(pasta_ibge_bronze, "censo2022_esgotamento_sanitario.parquet")) %>%
  mutate(
    cd_municipio_ibge = str_pad(as.character(codigo_ibge), 7, "left", "0"),
    pct = to_num(pct_domicilios, zero_se_hifen = TRUE),
    chave = if_else(str_detect(tipo_esgotamento, "Rede geral"), "pct_esgoto_adequado", "pct_sem_banheiro")
  ) %>%
  select(cd_municipio_ibge, chave, pct) %>%
  pivot_wider(names_from = chave, values_from = pct, values_fn = first)

raca <- read_parquet(path(pasta_ibge_bronze, "censo2022_cor_raca.parquet")) %>%
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

sexo <- read_parquet(path(pasta_ibge_bronze, "censo2022_sexo.parquet")) %>%
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

fato_indicadores <- pop %>%
  select(-nm_municipio_ibge) %>%
  left_join(pib, by = "cd_municipio_ibge") %>%
  left_join(pib_set, by = "cd_municipio_ibge") %>%
  left_join(alfa, by = "cd_municipio_ibge") %>%
  left_join(urb, by = "cd_municipio_ibge") %>%
  left_join(agua, by = "cd_municipio_ibge") %>%
  left_join(esgoto, by = "cd_municipio_ibge") %>%
  left_join(raca, by = "cd_municipio_ibge") %>%
  left_join(sexo, by = "cd_municipio_ibge") %>%
  mutate(
    pib_per_capita_reais = if_else(populacao_2022 > 0, pib_reais_2023 / populacao_2022, NA_real_)
  )

write_parquet(fato_indicadores, path(DADOS_PRATA, "fato_indicadores_municipio.parquet"), compression = "zstd")
message("✔ dados/prata/fato_indicadores_municipio.parquet salvo (", nrow(fato_indicadores), " municípios, ", ncol(fato_indicadores), " colunas)")
