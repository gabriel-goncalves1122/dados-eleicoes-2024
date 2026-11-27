# ==============================================================================
# INGESTÃO BRONZE 02: IBGE / SIDRA (BRASIL) -> 100% PARQUET
# ==============================================================================

if (file.exists("src/config.R")) source("src/config.R") else source("../../src/config.R")

library(tidyverse)
library(sidrar)
library(arrow)
library(fs)

options(timeout = 600)
PASTA_SAIDA <- path(DADOS_BRONZE, "ibge")
dir_create(PASTA_SAIDA)

baixar_sidra_com_retry <- function(api, tentativas = 3, espera_seg = 5, min_linhas = 5000) {
  for (i in seq_len(tentativas)) {
    res <- tryCatch(
      get_sidra(api = api),
      error = function(e) {
        message("⚠ Tentativa ", i, "/", tentativas, " falhou para ", api, ": ", e$message)
        NULL
      }
    )
    if (!is.null(res) && nrow(res) >= min_linhas) return(res)
    if (i < tentativas) Sys.sleep(espera_seg * i)
  }
  stop("❌ Falha definitiva ao consultar API SIDRA: ", api)
}

message("=== Iniciando Ingestão Bronze IBGE (Brasil - 100% Parquet) ===")

message("1. Baixando População Municipal (Tabela 4709)...")
baixar_sidra_com_retry("/t/4709/n6/all/v/93/p/2022") %>%
  select(codigo_ibge = `Município (Código)`, nome_municipio = `Município`, populacao = Valor) %>%
  write_parquet(path(PASTA_SAIDA, "populacao_2022.parquet"), compression = "zstd")

message("2. Baixando PIB Municipal Total (Tabela 5938)...")
baixar_sidra_com_retry("/t/5938/n6/all/v/37/p/last%201") %>%
  select(codigo_ibge = `Município (Código)`, nome_municipio = `Município`, pib = Valor, ano_pib = `Ano`) %>%
  write_parquet(path(PASTA_SAIDA, "pib_municipal.parquet"), compression = "zstd")

message("3. Baixando Composição Setorial do PIB 2021 (Tabela 5938)...")
baixar_sidra_com_retry("/t/5938/n6/all/v/37,513,514,525/p/2021") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, codigo_variavel = `Variável (Código)`, variavel = `Variável`, valor_mil_reais = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "pib_composicao_setorial.parquet"), compression = "zstd")

message("4. Baixando População por Cor ou Raça (Tabela 9605)...")
baixar_sidra_com_retry("/t/9605/n6/all/v/93/p/2022/c86/all") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, cor_raca = `Cor ou raça`, populacao = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_cor_raca.parquet"), compression = "zstd")

message("5. Baixando População por Sexo (Tabela 9514)...")
baixar_sidra_com_retry("/t/9514/n6/all/v/93/p/2022/c2/4,5/c287/100362") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, sexo = `Sexo`, populacao = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_sexo.parquet"), compression = "zstd")

message("6. Baixando Taxa de Alfabetização 15+ (Tabela 9543)...")
baixar_sidra_com_retry("/t/9543/n6/all/v/2513/p/2022/c2/6794/c86/95251/c287/100362") %>%
  select(codigo_ibge = `Município (Código)`, nome_municipio = `Município`, taxa_alfabetizacao = Valor) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_taxa_alfabetizacao.parquet"), compression = "zstd")

message("7. Baixando População Urbana vs. Rural (Tabela 9923)...")
baixar_sidra_com_retry("/t/9923/n6/all/v/93,1000093/p/2022/c1/1,2") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    codigo_variavel = `Variável (Código)`, variavel = `Variável`,
    ano = `Ano`, situacao_domicilio = `Situação do domicílio`, valor = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_urbana_rural.parquet"), compression = "zstd")

message("8. Baixando Esgotamento Sanitário (Tabela 6805)...")
baixar_sidra_com_retry("/t/6805/n6/all/v/1000381/p/2022/c11558/46290,92861") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, tipo_esgotamento = `Tipo de esgotamento sanitário`, pct_domicilios = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_esgotamento_sanitario.parquet"), compression = "zstd")

message("9. Baixando Abastecimento de Água (Tabela 6804)...")
baixar_sidra_com_retry("/t/6804/n6/all/v/1000381/p/2022/c301/31471") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, forma_abastecimento = `Principal forma de abastecimento de água`, pct_rede_geral = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_abastecimento_agua.parquet"), compression = "zstd")

message("🎉 Ingestão Bronze IBGE (9 arquivos Parquet - Brasil) concluída!")
