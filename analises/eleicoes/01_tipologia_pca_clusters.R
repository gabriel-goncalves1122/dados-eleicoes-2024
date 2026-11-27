# ==============================================================================
# ANÁLISE 01: TIPOLOGIA ESTRUTURAL DOS 5.569 MUNICÍPIOS (PCA + K-MEANS + TILE MAP)
# ==============================================================================
# Tese: O comportamento eleitoral segue eixos estruturais profundos (desenvolvimento,
# dependência pública, custo eleitoral e representatividade) além das divisas estaduais.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [01] Tipologia Estrutural Municipal (PCA + K-Means + Tile Grid UF) ===")

df <- ler_ouro("ouro_pca_municipios.parquet")

vars_pca <- c(
  "pib_per_capita_reais",
  "taxa_alfabetizacao_15mais",
  "pct_populacao_urbana",
  "pct_esgoto_adequado",
  "pct_adm_publica_vab_2021",
  "taxa_comparecimento_estimada",
  "gasto_campanha_per_capita",
  "custo_medio_voto_municipio",
  "pct_fundo_publico_municipio",
  "pct_cand_mulheres",
  "pct_eleitos_mulheres"
)

df_comp <- df %>%
  select(cd_municipio_tse, sg_uf, regiao, nm_municipio, porte_municipio, all_of(vars_pca)) %>%
  drop_na()

pca_res <- prcomp(df_comp[, vars_pca], center = TRUE, scale. = TRUE)

set.seed(42)
km <- kmeans(pca_res$x[, 1:4], centers = 4, nstart = 25)

df_clustered <- df_comp %>%
  mutate(
    PC1 = pca_res$x[, 1],
    PC2 = pca_res$x[, 2],
    cluster = factor(paste("Cluster", km$cluster))
  )

resumo_clusters <- df_clustered %>%
  group_by(cluster) %>%
  summarise(
    qtd_municipios = n(),
    pib_pc_med = median(pib_per_capita_reais),
    alfab_med = median(taxa_alfabetizacao_15mais),
    adm_pub_med = median(pct_adm_publica_vab_2021),
    gasto_pc_med = median(gasto_campanha_per_capita),
    custo_voto_med = median(custo_medio_voto_municipio),
    fundo_pub_med = median(pct_fundo_publico_municipio),
    eleit_mulh_med = median(pct_eleitos_mulheres),
    .groups = "drop"
  )
salvar_tabela(resumo_clusters, "01_centroides_clusters_municipais.csv")

# Cargas para Biplot
var_exp <- round(100 * pca_res$sdev^2 / sum(pca_res$sdev^2), 1)
cargas <- as.data.frame(pca_res$rotation[, 1:2]) %>%
  rownames_to_column("variavel") %>%
  mutate(PC1_s = PC1 * 4.5, PC2_s = PC2 * 4.5)

p_biplot <- ggplot(df_clustered, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(alpha = 0.35, size = 1.1) +
  stat_ellipse(level = 0.80, linewidth = 0.8) +
  geom_segment(
    data = cargas,
    aes(x = 0, y = 0, xend = PC1_s, yend = PC2_s),
    inherit.aes = FALSE,
    arrow = arrow(length = unit(0.18, "cm")),
    color = "black", alpha = 0.75
  ) +
  ggrepel::geom_text_repel(
    data = cargas,
    aes(x = PC1_s, y = PC2_s, label = variavel),
    inherit.aes = FALSE,
    size = 3, max.overlaps = 20, color = "black"
  ) +
  labs(
    title = "Tipologia Municipal Brasil 2024: Biplot PCA + K-Means (4 Clusters)",
    subtitle = paste0("Base: ", nrow(df_clustered), " municípios completos"),
    x = paste0("PC1 (", var_exp[1], "%)"),
    y = paste0("PC2 (", var_exp[2], "%)"),
    color = "Tipologia"
  ) +
  theme_minimal()
salvar_grafico(p_biplot, "01a_tipologia_pca_biplot.png", width = 11, height = 7)

# Tile-Grid Map das 26 UFs (predominância de Cluster por Estado)
grid_ufs <- tribble(
  ~sg_uf, ~col, ~row,
  "RR", 2, 1, "AP", 4, 1,
  "AM", 1, 2, "PA", 3, 2, "MA", 5, 2, "CE", 6, 2, "RN", 7, 2,
  "AC", 1, 3, "RO", 2, 3, "TO", 4, 3, "PI", 5, 3, "PE", 6, 3, "PB", 7, 3,
  "MT", 3, 4, "GO", 4, 4, "BA", 5, 4, "AL", 6, 4, "SE", 7, 4,
  "MS", 3, 5, "MG", 5, 5, "ES", 6, 5,
  "SP", 4, 6, "RJ", 5, 6,
  "PR", 4, 7,
  "SC", 4, 8,
  "RS", 4, 9
)

uf_dominante <- df_clustered %>%
  count(sg_uf, cluster) %>%
  group_by(sg_uf) %>%
  mutate(pct = 100 * n / sum(n)) %>%
  slice_max(pct, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  inner_join(grid_ufs, by = "sg_uf")

p_tile <- ggplot(uf_dominante, aes(x = col, y = -row, fill = cluster)) +
  geom_tile(color = "white", linewidth = 1, width = 0.92, height = 0.92) +
  geom_text(aes(label = paste0(sg_uf, "\n", round(pct, 0), "%")), size = 3.2, fontface = "bold") +
  coord_equal() +
  labs(
    title = "Predominância de Tipologia Eleitoral-Socioeconômica por UF (Brasil - 26 UFs)",
    subtitle = "Cada célula exibe o cluster K-Means mais frequente entre os municípios da UF",
    fill = "Cluster Dominante"
  ) +
  theme_void()
salvar_grafico(p_tile, "01b_mapa_tile_clusters_uf.png", width = 9, height = 8)
