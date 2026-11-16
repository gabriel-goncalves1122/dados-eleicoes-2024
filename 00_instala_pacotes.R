# ==============================================================================
# SCRIPT 00: INSTALAÇÃO DE DEPENDÊNCIAS DO PROJETO (ELEIÇÕES 2024 - MG & SP)
# ==============================================================================
# Este script prepara o ambiente instalando pacotes necessários.

if (is.null(getOption("repos")) || getOption("repos")["CRAN"] == "@CRAN@") {
  options(repos = c(CRAN = "https://cloud.r-project.org"))
}

pacotes_necessarios <- c(
  "tidyverse",   # Manipulação de dados (dplyr, tidyr, ggplot2, stringr, readr)
  "arrow",       # Processamento colunar ultra-rápido de Parquet e Streaming
  "fs",          # Manipulação consistente de diretórios e arquivos
  "here",        # Resolução automática da raiz do projeto (cross-platform)
  "curl",        # Downloads resilientes com suporte a timeout e retry
  "httr2",       # Requisições HTTP modernas
  "sidrar",      # Conexão com a API SIDRA do IBGE (Censo e PIB)
  "reactable",   # Tabelas interativas HTML
  "plotly",      # Gráficos analíticos interativos HTML
  "jsonlite",    # Manipulação de metadados JSON
  "duckdb"       # Engine analítica SQL de alta performance em memória/disco
)

pacotes_faltantes <- pacotes_necessarios[!(pacotes_necessarios %in% installed.packages()[, "Package"])]
if (length(pacotes_faltantes) > 0) {
  message("Instalando pacotes faltantes: ", paste(pacotes_faltantes, collapse = ", "))
  install.packages(pacotes_faltantes)
} else {
  message("✅ Todos os pacotes necessários já estão instalados.")
}

message("✅ Ambiente pronto para o processamento das Eleições 2024!")
