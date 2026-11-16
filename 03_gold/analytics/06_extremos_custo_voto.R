# ==============================================================================
# ANALYTICS 06: EXTREMOS DE CUSTO POR VOTO ENTRE PREFEITOS ELEITOS (2024)
# ==============================================================================

if (file.exists("utils_paths.R")) {
  source("utils_paths.R")
} else {
  source("../../utils_paths.R")
}
source("03_gold/analytics/_helpers_vis.R")

datamart <- read_parquet("03_gold/data/datamart_candidatos_2024.parquet")

eleitos <- datamart %>%
  filter(cd_cargo == 11L, is_eleito, !is.na(custo_por_voto), custo_por_voto > 0, total_votos >= 500)

extremos <- bind_rows(
  eleitos %>% slice_max(custo_por_voto, n = 10) %>% mutate(grupo = "10 Mais Caros"),
  eleitos %>% slice_min(custo_por_voto, n = 10) %>% mutate(grupo = "10 Mais Econômicos")
) %>%
  mutate(
    label_cand = paste0(nm_urna_candidato, " (", nm_municipio, "/", sg_uf, ")"),
    label_cand = fct_reorder(label_cand, custo_por_voto)
  )

g6 <- ggplot(extremos, aes(
  x = custo_por_voto, y = label_cand, fill = grupo,
  text = paste(
    "Prefeito:", nm_urna_candidato, " (", sg_partido, ")",
    "<br>Município:", nm_municipio, "-", sg_uf,
    "<br>Custo/Voto: R$", round(custo_por_voto, 2),
    "<br>Gasto Total: R$", format(round(total_gasto, 0), big.mark = "."),
    "<br>Votos:", format(total_votos, big.mark = ".")
  )
)) +
  geom_col() +
  scale_x_log10(labels = dollar_format(prefix = "R$ ")) +
  scale_fill_manual(values = c("10 Mais Caros" = "#e11d48", "10 Mais Econômicos" = "#059669")) +
  labs(
    title = "Extremos de Custo por Voto — Prefeitos Eleitos (2024 - MG & SP)",
    x = "Custo por Voto (R$ - Escala Log)", y = NULL, fill = "Grupo"
  ) +
  theme_minimal()

salvar_e_exibir_plotly(g6, "06_extremos_custo_voto.html")
