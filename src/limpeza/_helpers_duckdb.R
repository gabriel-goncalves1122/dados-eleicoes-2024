# ==============================================================================
# HELPERS DUCKDB PARA CAMADA PRATA (LIMPEZA COLUNAR E CONSTELAÇÃO)
# ==============================================================================

library(DBI)
library(duckdb)
library(fs)

sql_limpar <- function(col, upper = FALSE) {
  trimmed <- sprintf("REGEXP_REPLACE(TRIM(CAST(%s AS VARCHAR)), '\\s+', ' ', 'g')", col)
  val <- sprintf(
    "CASE WHEN %s IN ('#NULO#', '#NULO', '#NE#', '#NE', '-1', '-3', '-4', '') THEN NULL ELSE %s END",
    trimmed, trimmed
  )
  if (upper) sprintf("UPPER(%s)", val) else val
}

executar_copy_parquet <- function(con_db, select_sql, destino_parquet) {
  if (file_exists(destino_parquet)) file_delete(destino_parquet)
  sql <- sprintf(
    "COPY (%s) TO '%s' (FORMAT PARQUET, COMPRESSION 'ZSTD')",
    select_sql,
    normalizePath(destino_parquet, winslash = "/", mustWork = FALSE)
  )
  dbExecute(con_db, sql)
  dbGetQuery(
    con_db,
    sprintf("SELECT COUNT(*) AS n FROM read_parquet('%s')", normalizePath(destino_parquet, winslash = "/"))
  )$n[1]
}

com_conexao_duckdb <- function(fn) {
  con <- dbConnect(duckdb::duckdb())
  tryCatch(
    fn(con),
    finally = dbDisconnect(con, shutdown = TRUE)
  )
}
