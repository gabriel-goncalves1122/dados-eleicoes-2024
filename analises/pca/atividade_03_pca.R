# ==============================================================================
# ATIVIDADE 03 — ANÁLISE PRELIMINAR DE COMPONENTES PRINCIPAIS (PCA)
# Disciplina: PCO207 - Tópicos Especiais em Inteligência Artificial (Data Science em R)
# Aluno: Gabriel Gonçalves
# Base de dados: Datamart Integrado Eleições Municipais 2024 (TSE) + IBGE (MG & SP)
# ==============================================================================
#
# Objetivo: representar a base multivariada dos municípios de Minas Gerais (MG)
# e São Paulo (SP) em um espaço de menor dimensão, procurando preservar a maior
# quantidade possível de variabilidade dos dados socioeconômicos e eleitorais.
#
# Seguindo as orientações da Atividade 03 e o modelo do Prof. Carlos Silveira:
# - Envolve apenas variáveis numéricas, categóricas binárias e categóricas ordinais
#   (com as duas últimas convertidas para valores numéricos via fatores ordenados).
# - Variáveis nominais (como UF, nome do município e rótulo de porte) permanecem
#   fora da matriz ativa da PCA e são usadas apenas para colorir os indivíduos.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CARREGAMENTO DOS PACOTES
# ------------------------------------------------------------------------------
library(tidyverse)   # Manipulação de dados (dplyr, tidyr, forcats) e ggplot2
library(arrow)       # Leitura colunar de alta performance do arquivo .parquet
library(pheatmap)    # Mapas de calor (opcional/complementar)
library(FactoMineR)  # Implementa a função PCA()
library(factoextra)  # Visualização de resultados (fviz_eig, fviz_pca_*)
library(corrplot)    # Matriz de correlações / cargas entre variáveis e componentes
library(fastDummies) # Utilitário para variáveis dummy (mantido conforme padrão)

# Resolve dinamicamente a raiz do subprojeto Gabriel_Goncalves/
if (file.exists("src/config.R")) {
  source("src/config.R")
} else if (file.exists("Gabriel_Goncalves/src/config.R")) {
  source("Gabriel_Goncalves/src/config.R")
}

# ------------------------------------------------------------------------------
# 2. CARREGAMENTO E PREPARAÇÃO DOS DADOS
# ------------------------------------------------------------------------------
caminho_datamart <- file.path(DADOS_OURO, "ouro_pca_municipios.parquet")
if (!file.exists(caminho_datamart)) {
  stop(
    "Arquivo não encontrado em '", caminho_datamart, "'.\n",
    "Execute primeiro source('src/pipeline.R'); executar_pipeline('tudo') ",
    "para gerar as camadas Parquet localmente."
  )
}

dados_brutos <- read_parquet(caminho_datamart)

# Seleção das variáveis para a análise:
# - Identificação / Coloração (NÃO entram no cálculo da PCA):
#   sg_uf, nm_municipio, porte_municipio, prefeito_eleito_genero
# - Numéricas contínuas (IBGE + TSE):
#   pib_per_capita_reais, taxa_alfabetizacao_15mais, pct_populacao_urbana,
#   pct_esgoto_adequado, pct_adm_publica_vab_2021, taxa_comparecimento_estimada,
#   gasto_campanha_per_capita, custo_medio_voto_municipio,
#   pct_fundo_publico_municipio, pct_cand_mulheres, pct_eleitos_mulheres
# - Categórica Binária (convertida para numérica):
#   genero_pref_bin (de prefeito_eleito_genero: MASCULINO = 1, FEMININO = 2)
# - Categóricas Ordinais (convertidas para numéricas):
#   porte_num (de porte_municipio: 1 = Pequeno Porte I ... 5 = Metrópole)
#   instrucao_pref_num (de prefeito_eleito_instrucao: 1 = Lê e Escreve ... 7 = Superior Completo)

dados_prep <- dados_brutos |>
  select(
    # Variáveis auxiliares / nominais para coloração
    sg_uf,
    nm_municipio,
    porte_municipio,
    prefeito_eleito_genero,
    prefeito_eleito_instrucao,
    # Variáveis numéricas quantitativas
    pib_per_capita_reais,
    taxa_alfabetizacao_15mais,
    pct_populacao_urbana,
    pct_esgoto_adequado,
    pct_adm_publica_vab_2021,
    taxa_comparecimento_estimada,
    gasto_campanha_per_capita,
    custo_medio_voto_municipio,
    pct_fundo_publico_municipio,
    pct_cand_mulheres,
    pct_eleitos_mulheres
  ) |>
  # Remove casos com NA para manter alinhamento exato entre a matriz da PCA
  # e os vetores de coloração (evita imputação artificial em categóricas).
  drop_na() |>
  mutate(
    # Fator original preservado para legendas gráficas + Região geográfica (5 macro-regiões)
    sg_uf = factor(sg_uf),
    regiao = factor(case_when(
      sg_uf %in% c("AC", "AP", "AM", "PA", "RO", "RR", "TO") ~ "Norte",
      sg_uf %in% c("AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE") ~ "Nordeste",
      sg_uf %in% c("DF", "GO", "MT", "MS") ~ "Centro-Oeste",
      sg_uf %in% c("ES", "MG", "RJ", "SP") ~ "Sudeste",
      sg_uf %in% c("PR", "RS", "SC") ~ "Sul",
      TRUE ~ "Outra"
    )),
    prefeito_eleito_genero = factor(prefeito_eleito_genero),
    porte_municipio = fct_relevel(
      factor(porte_municipio),
      "Pequeno Porte I (<20k)",
      "Pequeno Porte II (20k-50k)",
      "Médio Porte (50k-100k)",
      "Grande Porte (100k-500k)",
      "Metrópole (>500k)"
    ),

    # 1) Categórica BINÁRIA convertida para numérica:
    # MASCULINO = 1, FEMININO = 2
    genero_pref_bin = prefeito_eleito_genero |>
      fct_relevel("MASCULINO", "FEMININO") |>
      as.numeric(),

    # 2) Categórica ORDINAL 1: Porte Populacional do Município (1 a 5)
    porte_num = as.numeric(porte_municipio),

    # 3) Categórica ORDINAL 2: Escolaridade do Prefeito Eleito (1 a 7)
    instrucao_pref_num = prefeito_eleito_instrucao |>
      fct_relevel(
        "LÊ E ESCREVE",
        "ENSINO FUNDAMENTAL INCOMPLETO",
        "ENSINO FUNDAMENTAL COMPLETO",
        "ENSINO MÉDIO INCOMPLETO",
        "ENSINO MÉDIO COMPLETO",
        "SUPERIOR INCOMPLETO",
        "SUPERIOR COMPLETO"
      ) |>
      as.numeric()
  )

# Inspeção rápida de completude
message("Observações completas analisadas na PCA: ", nrow(dados_prep), " municípios (Brasil - ", n_distinct(dados_prep$sg_uf), " UFs)")
stopifnot(sum(complete.cases(dados_prep)) == nrow(dados_prep))

# Matriz numérica ativa da PCA (apenas numéricas + binária + ordinais)
m <- dados_prep |>
  select(
    pib_per_capita_reais,
    taxa_alfabetizacao_15mais,
    pct_populacao_urbana,
    pct_esgoto_adequado,
    pct_adm_publica_vab_2021,
    taxa_comparecimento_estimada,
    gasto_campanha_per_capita,
    custo_medio_voto_municipio,
    pct_fundo_publico_municipio,
    pct_cand_mulheres,
    pct_eleitos_mulheres,
    genero_pref_bin,
    porte_num,
    instrucao_pref_num
  )

# ------------------------------------------------------------------------------
# 3. CÁLCULO DA PCA
# ------------------------------------------------------------------------------
# scale.unit = TRUE: padroniza as variáveis (média 0, variância 1), essencial
# pois temos escalas muito distintas (Reais, %, e códigos ordinais 1..7).
# graph = FALSE: geraremos as visualizações personalizadas com factoextra/corrplot.
m.pca <- m |> PCA(scale.unit = TRUE, ncp = ncol(m), graph = FALSE)

message("\n=== Tabela de Autovalores e Variância Explicada ===")
print(round(m.pca$eig, 3))

# Pasta opcional para salvar as figuras geradas localmente (ignorada no Git)
dir_figuras <- ANALISES_PCA_OUT
if (!dir.exists(dir_figuras)) dir.create(dir_figuras, recursive = TRUE)

# ------------------------------------------------------------------------------
# 4. RELAÇÃO ENTRE VARIÁVEIS E COMPONENTES (CORRPLOT)
# ------------------------------------------------------------------------------
col2 <- colorRampPalette(c("darkred", "white", "darkblue"))

png(file.path(dir_figuras, "01_corrplot_variaveis_componentes.png"), width = 1000, height = 800, res = 120)
corrplot(
  m.pca$var$cor,
  is.corr = FALSE,
  col = col2(20),
  col.lim = c(-1, 1),
  mar = c(0, 0, 2, 0),
  cl.offset = 0.2,
  tl.cex = 0.85,
  title = "Correlação entre Variáveis Originais e Componentes Principais (TSE + IBGE)"
)
dev.off()

corrplot(
  m.pca$var$cor,
  is.corr = FALSE,
  col = col2(20),
  col.lim = c(-1, 1),
  mar = c(0, 0, 2, 0),
  cl.offset = 0.2,
  tl.cex = 0.85,
  title = "Correlação entre Variáveis Originais e Componentes Principais (TSE + IBGE)"
)

# ------------------------------------------------------------------------------
# 5. VARIÂNCIA EXPLICADA — SCREE PLOT
# ------------------------------------------------------------------------------
p0 <- fviz_eig(
  m.pca,
  addlabels = TRUE,
  ylim = c(0, 45),
  main = "Scree Plot — Variância Explicada por Componente Principal"
)
print(p0)
ggsave(file.path(dir_figuras, "02_scree_plot.png"), p0, width = 9, height = 6, dpi = 150)

# ------------------------------------------------------------------------------
# 6. GRÁFICO DAS VARIÁVEIS — CÍRCULO DE CORRELAÇÕES
# ------------------------------------------------------------------------------
p1 <- fviz_pca_var(
  m.pca,
  col.var = "contrib",
  gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
  axes = c(1, 2),
  repel = TRUE,
  title = "Círculo de Correlações — Variáveis Ativas (PC1 vs PC2)"
)
print(p1)
ggsave(file.path(dir_figuras, "03_circulo_correlacoes_var.png"), p1, width = 9, height = 7, dpi = 150)

# ------------------------------------------------------------------------------
# 7. GRÁFICO DOS INDIVÍDUOS — COLORAÇÃO POR REGIÃO DO BRASIL
# ------------------------------------------------------------------------------
# regiao não participa da matriz ativa da PCA; serve para verificar se os
# municípios das 5 macrorregiões se separam espontaneamente no espaço reduzido.
p2 <- fviz_pca_ind(
  m.pca,
  geom.ind = "point",
  col.ind = dados_prep$regiao,
  palette = c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00"),
  addEllipses = TRUE,
  ellipse.level = 0.95,
  legend.title = "Região",
  axes = c(1, 2),
  title = "Municípios no Espaço PCA (PC1 vs PC2) — Colorido por Região (Brasil)"
)
print(p2)
ggsave(file.path(dir_figuras, "04_individuos_por_regiao.png"), p2, width = 9, height = 7, dpi = 150)

# ------------------------------------------------------------------------------
# 8. BIPLOTS — INDIVÍDUOS E VARIÁVEIS NO MESMO PLANO
# ------------------------------------------------------------------------------
# 8.1 — Biplot colorido por Região do Brasil
p3 <- fviz_pca_biplot(
  m.pca,
  axes = c(1, 2),
  geom.ind = "point",
  col.ind = dados_prep$regiao,
  palette = c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00"),
  addEllipses = TRUE,
  col.var = "black",
  repel = TRUE,
  legend.title = "Região",
  title = "Biplot PCA — Municípios Brasileiros e Variáveis Eleitorais/IBGE"
)
print(p3)
ggsave(file.path(dir_figuras, "05_biplot_por_regiao.png"), p3, width = 10, height = 7, dpi = 150)

# 8.2 — Biplot colorido por Porte do Município (variável ordinal original)
p4 <- fviz_pca_biplot(
  m.pca,
  axes = c(1, 2),
  geom.ind = "point",
  col.ind = dados_prep$porte_municipio,
  col.var = "black",
  repel = TRUE,
  legend.title = "Porte do Município",
  title = "Biplot PCA — Agrupamento por Porte Populacional"
)
print(p4)
ggsave(file.path(dir_figuras, "06_biplot_por_porte.png"), p4, width = 10, height = 7, dpi = 150)

# 8.3 — Biplot colorido por Gênero do Prefeito Eleito
# ATENÇÃO (conforme nota do Prof. Carlos Silveira): genero_pref_bin faz parte da
# matriz ativa m; portanto, a separação visual reflete parcialmente sua inclusão.
p5 <- fviz_pca_biplot(
  m.pca,
  axes = c(1, 2),
  geom.ind = "point",
  col.ind = dados_prep$prefeito_eleito_genero,
  palette = c("#E377C2", "#2CA02C"),
  col.var = "black",
  repel = TRUE,
  legend.title = "Gênero (Prefeito)",
  title = "Biplot PCA — Colorido por Gênero do Prefeito Eleito"
)
print(p5)
ggsave(file.path(dir_figuras, "07_biplot_por_genero_prefeito.png"), p5, width = 10, height = 7, dpi = 150)

# ------------------------------------------------------------------------------
# 9. ALTERNATIVA DIDÁTICA: PCA EXCLUSIVAMENTE COM VARIÁVEIS CONTÍNUAS
# ------------------------------------------------------------------------------
# Remove as variáveis categóricas convertidas (binária e ordinais) da matriz ativa,
# usando sg_uf e porte_municipio exclusivamente como fatores visuais externos.
m_continuo <- m |>
  select(-genero_pref_bin, -porte_num, -instrucao_pref_num)

pca_continuo <- PCA(m_continuo, scale.unit = TRUE, ncp = ncol(m_continuo), graph = FALSE)

p6 <- fviz_pca_biplot(
  pca_continuo,
  geom.ind = "point",
  habillage = dados_prep$regiao,
  addEllipses = TRUE,
  col.var = "black",
  repel = TRUE,
  title = "PCA Alternativa (Apenas Contínuas) — Municípios por Região"
)
print(p6)
ggsave(file.path(dir_figuras, "08_biplot_apenas_continuas_regiao.png"), p6, width = 10, height = 7, dpi = 150)

message("\n✅ Análise PCA (Atividade 03) finalizada! Figuras salvas em: ", dir_figuras)
