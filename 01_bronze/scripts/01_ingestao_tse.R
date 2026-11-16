# ==============================================================================
# BRONZE 01: INGESTÃO DE DADOS DO TSE 2024 (MG & SP) -> 100% PARQUET
# ==============================================================================
# Baixa os 4 ZIPs essenciais para pasta temporária, extrai apenas MG e SP,
# converte em streaming para Parquet (ZSTD) e descarta CSVs/ZIPs temporários.

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}

library(tidyverse)
library(arrow)
library(fs)

options(timeout = 1800)
UFS_ALVO <- c("MG", "SP")
PASTA_SAIDA <- "01_bronze/data/tse"
dir_create(PASTA_SAIDA)

datasets_tse <- list(
  candidatos = list(
    nome = "Candidatos (consulta_cand_2024)",
    url = "https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2024.zip",
    padrao_csv = "consulta_cand_2024_(MG|SP)\\.csv$"
  ),
  bens = list(
    nome = "Bens Declarados (bem_candidato_2024)",
    url = "https://cdn.tse.jus.br/estatistica/sead/odsele/bem_candidato/bem_candidato_2024.zip",
    padrao_csv = "bem_candidato_2024_(MG|SP)\\.csv$"
  ),
  votacao = list(
    nome = "Votação Nominal MunZona (votacao_candidato_munzona_2024)",
    url = "https://cdn.tse.jus.br/estatistica/sead/odsele/votacao_candidato_munzona/votacao_candidato_munzona_2024.zip",
    padrao_csv = "votacao_candidato_munzona_2024_(MG|SP)\\.csv$"
  ),
  contas = list(
    nome = "Prestação de Contas Candidatos 2024",
    url = "https://cdn.tse.jus.br/estatistica/sead/odsele/prestacao_contas/prestacao_de_contas_eleitorais_candidatos_2024.zip",
    alvos = list(
      receitas = "receitas_candidatos_2024_(MG|SP)\\.csv$",
      despesas = "despesas_contratadas_candidatos_2024_(MG|SP)\\.csv$"
    )
  )
)

converter_csvs_para_parquet <- function(arquivos_csv, destino_parquet) {
  ds <- open_dataset(arquivos_csv, format = "csv", delimiter = ";")
  write_parquet(collect(ds), destino_parquet, compression = "zstd")
  message("✔ Salvo em Parquet: ", destino_parquet)
}

tmp_dir <- path(tempdir(), "tse_2024_ingest")
dir_create(tmp_dir)

for (chave in names(datasets_tse)) {
  item <- datasets_tse[[chave]]
  message("\n--- [Bronze TSE] ", item$nome, " ---")
  zip_tmp <- path(tmp_dir, paste0(chave, ".zip"))
  ext_tmp <- path(tmp_dir, chave)
  dir_create(ext_tmp)

  download.file(item$url, destfile = zip_tmp, mode = "wb", method = "curl", quiet = FALSE)
  nomes_zip <- unzip(zip_tmp, list = TRUE)$Name

  if (!is.null(item$alvos)) {
    for (subnome in names(item$alvos)) {
      arqs <- nomes_zip[str_detect(nomes_zip, regex(item$alvos[[subnome]], ignore_case = TRUE))]
      unzip(zip_tmp, files = arqs, exdir = ext_tmp, overwrite = TRUE)
      converter_csvs_para_parquet(path(ext_tmp, arqs), path(PASTA_SAIDA, paste0(subnome, ".parquet")))
    }
  } else {
    arqs <- nomes_zip[str_detect(nomes_zip, regex(item$padrao_csv, ignore_case = TRUE))]
    unzip(zip_tmp, files = arqs, exdir = ext_tmp, overwrite = TRUE)
    converter_csvs_para_parquet(path(ext_tmp, arqs), path(PASTA_SAIDA, paste0(chave, ".parquet")))
  }

  dir_delete(ext_tmp)
  file_delete(zip_tmp)
}

dir_delete(tmp_dir)
message("\n🎉 Ingestão Bronze TSE (100% Parquet, MG & SP) concluída!")
