# ==============================================================================
# CONFIGURAÇÃO CENTRAL DE CAMINHOS: PROJETO ELEIÇÕES 2024 (BRASIL)
# ==============================================================================
# Resolve dinamicamente a raiz de Gabriel_Goncalves/ e define todas as pastas
# de dados (Bronze, Prata, Ouro), análises e documentação em um só lugar.

obter_raiz_projeto <- function() {
  caminho_atual <- getwd()
  for (i in 1:6) {
    if (file.exists(file.path(caminho_atual, "src", "config.R")) ||
        file.exists(file.path(caminho_atual, "00_instala_pacotes.R"))) {
      return(caminho_atual)
    }
    caminho_pai <- dirname(caminho_atual)
    if (caminho_pai == caminho_atual) break
    caminho_atual <- caminho_pai
  }
  if (dir.exists("Gabriel_Goncalves") &&
      file.exists(file.path("Gabriel_Goncalves", "src", "config.R"))) {
    return(normalizePath("Gabriel_Goncalves"))
  }
  return(getwd())
}

RAIZ_PROJETO <- obter_raiz_projeto()
setwd(RAIZ_PROJETO)
message("📁 Raiz do projeto definida em: ", RAIZ_PROJETO)

# Caminhos centralizados das camadas de dados (padrão Medalhão)
DADOS_BRONZE <- "dados/bronze"
DADOS_PRATA  <- "dados/prata"
DADOS_OURO   <- "dados/ouro"

# Caminhos de documentação e saídas analíticas
DOCS_CATALOGO     <- "docs/catalogo"
ANALISES_PCA_OUT  <- "analises/pca/graficos"
ANALISES_ELEI_OUT <- "analises/eleicoes/output"
