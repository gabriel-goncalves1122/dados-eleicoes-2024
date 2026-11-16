# ==============================================================================
# UTILITÁRIO: RESOLUÇÃO DINÂMICA DA RAIZ DO PROJETO (100% PARQUET MEDALLION)
# ==============================================================================
# Garante que os scripts rodem tanto da raiz quanto de qualquer subpasta
# (01_bronze/scripts, 02_silver/scripts, 03_gold/scripts, 03_gold/analytics).

obter_raiz_projeto <- function() {
  caminho_atual <- getwd()
  for (i in 1:6) {
    if (file.exists(file.path(caminho_atual, "README.md")) ||
        file.exists(file.path(caminho_atual, ".git"))) {
      return(caminho_atual)
    }
    caminho_pai <- dirname(caminho_atual)
    if (caminho_pai == caminho_atual) break
    caminho_atual <- caminho_pai
  }
  if (requireNamespace("here", quietly = TRUE)) {
    return(here::here())
  }
  return(getwd())
}

raiz_projeto <- obter_raiz_projeto()
setwd(raiz_projeto)
message("📁 Raiz do projeto definida em: ", raiz_projeto)
