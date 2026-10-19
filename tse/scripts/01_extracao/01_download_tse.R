# ==============================================================================
# SCRIPT 01: COLETA DE DADOS TSE (ELEIÇÕES GERAIS 2022)
# ==============================================================================
# Este script deve ser executado a partir da raiz do projeto.
# Definimos a raiz para garantir consistência nos caminhos.
setwd("~/Documentos/UNIFEI/PERIODOS/MESTRADO/R")

library(tidyverse)
library(electionsBR)
library(arrow)
library(fs)

# Garantindo que as pastas do TSE existem
dir_create("tse/data/01_raw/parquet")
dir_create("tse/data/01_raw/csv")

message("=== Iniciando Coleta TSE (2022) ===")

# ------------------------------------------------------------------------------
# 1. CANDIDATOS (Brasil todo)
# ------------------------------------------------------------------------------
message("Baixando base de Candidatos...")
candidatos <- elections_tse(year = 2022, type = "candidate")

# Salvamento Dual-Format
write_parquet(candidatos, "tse/data/01_raw/parquet/candidatos.parquet")
write_csv(candidatos, "tse/data/01_raw/csv/candidatos.csv")

rm(candidatos); gc()

# ------------------------------------------------------------------------------
# 2. VOTAÇÃO NOMINAL (Download em Blocos por Estado para não quebrar a memória)
# ------------------------------------------------------------------------------
message("Baixando base de Votação Nominal por UF (Isso vai demorar!)...")

# Lista de todos os estados brasileiros
ufs <- c("AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", "MS", 
         "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", 
         "SE", "SP", "TO")

# Criamos uma pasta específica para guardar o arquivo de cada estado separado
dir_create("tse/data/01_raw/votacao_nominal")

for(estado in ufs) {
  arquivo_destino <- paste0("tse/data/01_raw/votacao_nominal/votacao_", estado, ".parquet")
  
  # Pula se já baixou (bom para caso a internet caia no meio do processo)
  if(file_exists(arquivo_destino)) {
    message("Votação ", estado, " já existe. Pulando...")
    next
  }
  
  message("Baixando Votação de ", estado, "...")
  tryCatch({
    # O pacote baixa apenas o zip específico desse estado, evitando o erro de > 4GB
    vot_uf <- elections_tse(year = 2022, type = "vote_mun_zone", uf = estado)
    write_parquet(vot_uf, arquivo_destino)
    rm(vot_uf); gc()
  }, error = function(e) {
    message("Erro ao baixar ", estado, ": ", e$message)
  })
}

# ------------------------------------------------------------------------------
# 3. PRESTAÇÃO DE CONTAS (A implementar futuramente)
# ------------------------------------------------------------------------------
# Como o pacote electionsBR não suporta mais o download automático das receitas,
# o ideal é baixar o CSV "receitas_candidatos_2022_BRASIL.csv" direto do site de 
# Dados Abertos do TSE e colocar manualmente na pasta tse/data/01_raw/

message("✅ Coleta TSE finalizada com sucesso!")
