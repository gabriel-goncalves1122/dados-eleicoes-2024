# ==============================================================================
# BRONZE 03: INGESTÃO DA TABELA DE-PARA (TSE <-> IBGE) -> 100% PARQUET
# ==============================================================================
# Mapeia chaves entre Código TSE (5 dígitos) e Código IBGE (7 dígitos) para MG/SP.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

dir_create("01_bronze/data")

url_depara <- "https://raw.githubusercontent.com/betafcc/Municipios-Brasileiros-TSE/master/municipios_brasileiros_tse.csv"
tmp_csv <- tempfile(fileext = ".csv")

message("📥 Baixando tabela De-Para oficial (TSE <-> IBGE)...")
download.file(url_depara, destfile = tmp_csv, mode = "wb")

depara_tse_ibge <- read_csv(tmp_csv, col_types = cols(.default = "c")) %>%
  mutate(
    codigo_tse = str_pad(as.character(codigo_tse), width = 5, side = "left", pad = "0"),
    codigo_ibge = str_pad(as.character(codigo_ibge), width = 7, side = "left", pad = "0"),
    codigo_ibge_6 = substr(codigo_ibge, 1, 6),
    uf = str_to_upper(uf)
  ) %>%
  filter(uf %in% c("MG", "SP")) %>%
  select(codigo_tse, codigo_ibge, codigo_ibge_6, uf, nome_municipio_tse = nome_municipio, capital)

unlink(tmp_csv)

write_parquet(depara_tse_ibge, "01_bronze/data/depara_tse_ibge.parquet", compression = "zstd")
message("✅ De-Para salvo em 01_bronze/data/depara_tse_ibge.parquet (", nrow(depara_tse_ibge), " municípios)")
