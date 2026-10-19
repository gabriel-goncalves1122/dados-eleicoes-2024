# ==============================================================================
# SCRIPT 00: INSTALAÇÃO DE DEPENDÊNCIAS DO PROJETO
# ==============================================================================
# Rode este script apenas uma vez na sua máquina para preparar o ambiente.

# Força o uso do repositório da Posit para Linux (Ubuntu), garantindo 
# a instalação de versões pré-compiladas (binários) e evitando falhas.
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"))

pacotes_necessarios <- c(
  "tidyverse",   # Manipulação de dados (dplyr, tidyr, ggplot2)
  "electionsBR", # Conexão com repositório do TSE
  "sidrar",      # Conexão com API do IBGE
  "arrow",       # Leitura e escrita ultra-rápida de Parquet
  "fs",          # Manipulação de diretórios
  "reactable",   # Tabelas interativas html
  "plotly",      # Gráficos interativos html
  "here"         # Para navegar nas pastas facilmente
)

# Instala apenas os que não estão instalados
pacotes_faltantes <- pacotes_necessarios[!(pacotes_necessarios %in% installed.packages()[,"Package"])]
if(length(pacotes_faltantes)) install.packages(pacotes_faltantes)

message("✅ Ambiente pronto! Todos os pacotes instalados.")
