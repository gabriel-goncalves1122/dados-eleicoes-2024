# ==============================================================================
# INGESTÃO BRONZE 01: DADOS DO TSE 2024 (BRASIL - 27 UFs) -> PARQUET ÚNICO
# ==============================================================================
# Baixa os 4 ZIPs oficiais do CDN do TSE para pasta temporária, extrai os
# arquivos estaduais (excluindo *_BRASIL.csv e *_ZZ.csv) e converte em streaming
# C++ multithread via DuckDB direto para 1 arquivo .parquet (ZSTD) por tabela.

if (file.exists("src/config.R")) source("src/config.R") else source("../../src/config.R")

library(tidyverse)
library(duckdb)
library(fs)

options(timeout = 3600)
PASTA_SAIDA <- path(DADOS_BRONZE, "tse")
dir_create(PASTA_SAIDA)

datasets_tse <- list(
  candidatos = list(
    nome = "Candidatos (consulta_cand_2024)",
    url = "https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2024.zip",
    padrao_csv = "consulta_cand_2024_[A-Z]{2}\\.csv$"
  ),
  bens = list(
    nome = "Bens Declarados (bem_candidato_2024)",
    url = "https://cdn.tse.jus.br/estatistica/sead/odsele/bem_candidato/bem_candidato_2024.zip",
    padrao_csv = "bem_candidato_2024_[A-Z]{2}\\.csv$"
  ),
  votacao = list(
    nome = "Votação Nominal MunZona (votacao_candidato_munzona_2024)",
    url = "https://cdn.tse.jus.br/estatistica/sead/odsele/votacao_candidato_munzona/votacao_candidato_munzona_2024.zip",
    padrao_csv = "votacao_candidato_munzona_2024_[A-Z]{2}\\.csv$"
  ),
  contas = list(
    nome = "Prestação de Contas Candidatos 2024",
    url = "https://cdn.tse.jus.br/estatistica/sead/odsele/prestacao_contas/prestacao_de_contas_eleitorais_candidatos_2024.zip",
    alvos = list(
      receitas = "receitas_candidatos_2024_[A-Z]{2}\\.csv$",
      despesas = "despesas_contratadas_candidatos_2024_[A-Z]{2}\\.csv$"
    )
  )
)

baixar_com_retry <- function(url, destfile, tentativas = 3) {
  for (i in seq_len(tentativas)) {
    ok <- tryCatch({
      status <- download.file(
        url,
        destfile = destfile,
        mode = "wb",
        method = "curl",
        extra = c("-L", "--retry", "3", "--retry-delay", "5", "--fail"),
        quiet = FALSE
      )
      status == 0 && file.exists(destfile) && file.size(destfile) > 0
    }, error = function(e) {
      message("⚠ Tentativa ", i, "/", tentativas, " falhou: ", e$message)
      FALSE
    })
    if (ok) return(invisible(TRUE))
    if (file.exists(destfile)) file_delete(destfile)
    if (i < tentativas) Sys.sleep(5 * i)
  }
  stop("❌ Falha definitiva ao baixar: ", url)
}

selecionar_csvs_uf <- function(nomes_zip, padrao) {
  arqs <- nomes_zip[str_detect(nomes_zip, regex(padrao, ignore_case = TRUE))]
  arqs[!str_detect(arqs, regex("_(BRASIL|ZZ)\\.csv$", ignore_case = TRUE))]
}

converter_csvs_para_parquet <- function(arquivos_csv, destino_parquet) {
  if (length(arquivos_csv) == 0) stop("Nenhum CSV encontrado para ", destino_parquet)
  if (file_exists(destino_parquet)) file_delete(destino_parquet)

  con_db <- dbConnect(duckdb::duckdb())
  on.exit(dbDisconnect(con_db, shutdown = TRUE), add = TRUE)

  arqs_norm <- paste0("'", normalizePath(arquivos_csv, winslash = "/"), "'", collapse = ", ")
  destino_norm <- normalizePath(destino_parquet, winslash = "/", mustWork = FALSE)

  sql <- sprintf(
    "COPY (SELECT * FROM read_csv([%s], delim=';', quote='\"', escape='\"', header=true, all_varchar=true, encoding='latin-1', union_by_name=true)) TO '%s' (FORMAT PARQUET, COMPRESSION 'ZSTD')",
    arqs_norm,
    destino_norm
  )
  dbExecute(con_db, sql)
  message("✔ Salvo em Parquet (DuckDB C++): ", destino_parquet, " (", length(arquivos_csv), " CSVs)")
}

tmp_dir <- path(tempdir(), "tse_2024_ingest_br")
dir_create(tmp_dir)

for (chave in names(datasets_tse)) {
  item <- datasets_tse[[chave]]
  message("\n--- [Bronze TSE] ", item$nome, " ---")
  zip_tmp <- path(tmp_dir, paste0(chave, ".zip"))
  ext_tmp <- path(tmp_dir, chave)
  dir_create(ext_tmp)

  baixar_com_retry(item$url, zip_tmp)
  nomes_zip <- unzip(zip_tmp, list = TRUE)$Name

  if (!is.null(item$alvos)) {
    for (subnome in names(item$alvos)) {
      arqs <- selecionar_csvs_uf(nomes_zip, item$alvos[[subnome]])
      unzip(zip_tmp, files = arqs, exdir = ext_tmp, overwrite = TRUE)
      converter_csvs_para_parquet(path(ext_tmp, arqs), path(PASTA_SAIDA, paste0(subnome, ".parquet")))
      file_delete(path(ext_tmp, arqs))
    }
  } else {
    arqs <- selecionar_csvs_uf(nomes_zip, item$padrao_csv)
    unzip(zip_tmp, files = arqs, exdir = ext_tmp, overwrite = TRUE)
    converter_csvs_para_parquet(path(ext_tmp, arqs), path(PASTA_SAIDA, paste0(chave, ".parquet")))
  }

  dir_delete(ext_tmp)
  file_delete(zip_tmp)
}

dir_delete(tmp_dir)
message("\n🎉 Ingestão Bronze TSE (Brasil completo) concluída!")
