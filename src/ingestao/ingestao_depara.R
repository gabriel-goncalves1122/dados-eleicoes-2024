# ==============================================================================
# INGESTÃO BRONZE 03: TABELA DE-PARA (TSE <-> IBGE - BRASIL) -> 100% PARQUET
# ==============================================================================

if (file.exists("src/config.R")) source("src/config.R") else source("../../src/config.R")

library(tidyverse)
library(arrow)
library(fs)

dir_create(DADOS_BRONZE)

url_depara <- "https://raw.githubusercontent.com/betafcc/Municipios-Brasileiros-TSE/master/municipios_brasileiros_tse.csv"
tmp_csv <- tempfile(fileext = ".csv")

message("📥 Baixando tabela De-Para oficial (TSE <-> IBGE - Brasil)...")
status_dl <- download.file(
  url_depara,
  destfile = tmp_csv,
  mode = "wb",
  method = "curl",
  extra = c("-L", "--retry", "3", "--retry-delay", "5", "--fail")
)
if (status_dl != 0 || !file.exists(tmp_csv) || file.size(tmp_csv) == 0) {
  stop("❌ Falha ao baixar tabela De-Para de: ", url_depara)
}

depara_tse_ibge <- read_csv(tmp_csv, col_types = cols(.default = "c")) %>%
  mutate(
    codigo_tse = str_pad(as.character(codigo_tse), width = 5, side = "left", pad = "0"),
    codigo_ibge = str_pad(as.character(codigo_ibge), width = 7, side = "left", pad = "0"),
    codigo_ibge_6 = substr(codigo_ibge, 1, 6),
    uf = str_to_upper(str_squish(uf))
  ) %>%
  filter(!is.na(codigo_tse), !is.na(codigo_ibge), !uf %in% c("ZZ", "VT", "")) %>%
  distinct(codigo_tse, .keep_all = TRUE) %>%
  select(codigo_tse, codigo_ibge, codigo_ibge_6, uf, nome_municipio_tse = nome_municipio, capital)

if (nrow(depara_tse_ibge) < 5500) {
  stop("❌ Tabela De-Para inesperadamente incompleta (", nrow(depara_tse_ibge), " linhas).")
}

unlink(tmp_csv)

destino <- path(DADOS_BRONZE, "depara_tse_ibge.parquet")
write_parquet(depara_tse_ibge, destino, compression = "zstd")
message("✅ De-Para Brasil salvo em ", destino, " (", nrow(depara_tse_ibge), " municípios, ", n_distinct(depara_tse_ibge$uf), " UFs)")
