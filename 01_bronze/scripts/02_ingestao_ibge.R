# ==============================================================================
# BRONZE 02: INGESTÃO UNIFICADA IBGE / SIDRA -> 100% PARQUET
# ==============================================================================
# Consolida em um único script todas as extrações do IBGE (Censo 2022 e PIB
# Municipal Setorial), salvando exclusivamente no formato Parquet (ZSTD).

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(sidrar)
library(arrow)
library(fs)

PASTA_SAIDA <- "01_bronze/data/ibge"
dir_create(PASTA_SAIDA)

message("=== Iniciando Ingestão Bronze IBGE (100% Parquet) ===")

# 1. População Total (Censo 2022 - Tabela 4709)
message("1. Baixando População Municipal (Tabela 4709)...")
get_sidra(api = "/t/4709/n6/all/v/93/p/2022") %>%
  select(codigo_ibge = `Município (Código)`, nome_municipio = `Município`, populacao = Valor) %>%
  write_parquet(path(PASTA_SAIDA, "populacao_2022.parquet"), compression = "zstd")

# 2. PIB Municipal Total (Tabela 5938)
message("2. Baixando PIB Municipal Total (Tabela 5938)...")
get_sidra(api = "/t/5938/n6/all/v/37/p/last%201") %>%
  select(codigo_ibge = `Município (Código)`, nome_municipio = `Município`, pib = Valor, ano_pib = `Ano`) %>%
  write_parquet(path(PASTA_SAIDA, "pib_municipal.parquet"), compression = "zstd")

# 3. Composição Setorial do PIB (Tabela 5938 - último ano completo: 2021)
message("3. Baixando Composição Setorial do PIB 2021 (Tabela 5938)...")
get_sidra(api = "/t/5938/n6/all/v/37,513,514,525/p/2021") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, codigo_variavel = `Variável (Código)`, variavel = `Variável`, valor_mil_reais = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "pib_composicao_setorial.parquet"), compression = "zstd")

# 4. Cor ou Raça (Censo 2022 - Tabela 9605)
message("4. Baixando População por Cor ou Raça (Tabela 9605)...")
get_sidra(api = "/t/9605/n6/all/v/93/p/2022/c86/all") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, cor_raca = `Cor ou raça`, populacao = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_cor_raca.parquet"), compression = "zstd")

# 5. Sexo (Censo 2022 - Tabela 9514)
message("5. Baixando População por Sexo (Tabela 9514)...")
get_sidra(api = "/t/9514/n6/all/v/93/p/2022/c2/4,5/c287/100362") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, sexo = `Sexo`, populacao = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_sexo.parquet"), compression = "zstd")

# 6. Taxa de Alfabetização 15+ anos (Censo 2022 - Tabela 9543)
message("6. Baixando Taxa de Alfabetização 15+ (Tabela 9543)...")
get_sidra(api = "/t/9543/n6/all/v/2513/p/2022/c2/6794/c86/95251/c287/100362") %>%
  select(codigo_ibge = `Município (Código)`, nome_municipio = `Município`, taxa_alfabetizacao = Valor) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_taxa_alfabetizacao.parquet"), compression = "zstd")

# 7. População Urbana vs. Rural (Censo 2022 - Tabela 9923)
message("7. Baixando População Urbana vs. Rural (Tabela 9923)...")
get_sidra(api = "/t/9923/n6/all/v/93,1000093/p/2022/c1/1,2") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    codigo_variavel = `Variável (Código)`, variavel = `Variável`,
    ano = `Ano`, situacao_domicilio = `Situação do domicílio`, valor = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_urbana_rural.parquet"), compression = "zstd")

# 8. Esgotamento Sanitário (Censo 2022 - Tabela 6805)
message("8. Baixando Esgotamento Sanitário (Tabela 6805)...")
get_sidra(api = "/t/6805/n6/all/v/1000381/p/2022/c11558/46290,92861") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, tipo_esgotamento = `Tipo de esgotamento sanitário`, pct_domicilios = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_esgotamento_sanitario.parquet"), compression = "zstd")

# 9. Abastecimento de Água (Censo 2022 - Tabela 6804)
message("9. Baixando Abastecimento de Água (Tabela 6804)...")
get_sidra(api = "/t/6804/n6/all/v/1000381/p/2022/c301/31471") %>%
  select(
    codigo_ibge = `Município (Código)`, nome_municipio = `Município`,
    ano = `Ano`, forma_abastecimento = `Principal forma de abastecimento de água`, pct_rede_geral = Valor
  ) %>%
  write_parquet(path(PASTA_SAIDA, "censo2022_abastecimento_agua.parquet"), compression = "zstd")

message("🎉 Ingestão Bronze IBGE (9 arquivos Parquet) concluída!")
