# ==============================================================================
# HELPERS DA CAMADA OURO (REUTILIZA DUCKDB DA PRATA)
# ==============================================================================

if (file.exists("src/config.R")) {
  source("src/config.R")
  source("src/limpeza/_helpers_duckdb.R")
} else {
  source("../../src/config.R")
  source("../limpeza/_helpers_duckdb.R")
}

library(fs)
dir_create(DADOS_OURO)

prata_sql <- function(arquivo) {
  normalizePath(path(DADOS_PRATA, arquivo), winslash = "/")
}

ouro_dest <- function(arquivo) {
  path(DADOS_OURO, arquivo)
}

sql_macro_categoria_despesa <- function(col = "ds_origem_despesa") {
  sprintf("
    CASE
      WHEN CONTAINS(UPPER(COALESCE(%s, '')), 'IMPULSIONAMENTO')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'INTERNET') THEN 'Impulsionamento Digital'
      WHEN CONTAINS(UPPER(COALESCE(%s, '')), 'IMPRESSO')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'ADESIVO')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'BANNER') THEN 'Papel e Adesivos'
      WHEN CONTAINS(UPPER(COALESCE(%s, '')), 'MILITÂNCIA')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'PESSOAL') THEN 'Militância e Pessoal'
      WHEN CONTAINS(UPPER(COALESCE(%s, '')), 'ADVOCATÍCIOS')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'CONTÁBEIS') THEN 'Jurídico e Contábil'
      WHEN CONTAINS(UPPER(COALESCE(%s, '')), 'RÁDIO')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'TELEVISÃO')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'VÍDEO') THEN 'Rádio, TV e Vídeo'
      WHEN CONTAINS(UPPER(COALESCE(%s, '')), 'COMBUSTÍVEIS')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'VEÍCULOS')
        OR CONTAINS(UPPER(COALESCE(%s, '')), 'TRANSPORTE') THEN 'Logística e Combustível'
      ELSE 'Outros Serviços'
    END
  ", col, col, col, col, col, col, col, col, col, col, col, col, col, col, col)
}
