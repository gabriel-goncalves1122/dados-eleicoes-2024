# ==============================================================================
# ANÁLISE 04: PARTIDOS DE CÚPULA VS. PARTIDOS CAPILARES (CENTRALIZAÇÃO PARTIDÁRIA)
# ==============================================================================
# Tese: Alta centralização no Diretório Nacional não garante menor custo por eleito;
# há legendas capilares altamente eficientes e máquinas nacionais de custo elevado.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [04] Centralização Partidária e Custo por Eleito ===")

df <- ler_ouro("ouro_centralizacao_partidaria.parquet")

resumo_partido <- df %>%
  group_by(sg_partido) %>%
  summarise(
    qtd_candidatos = sum(qtd_candidatos),
    qtd_eleitos = sum(qtd_eleitos),
    total_arrecadado = sum(total_arrecadado),
    vl_dir_nacional = sum(vl_dir_nacional),
    vl_dir_estadual = sum(vl_dir_estadual),
    vl_dir_municipal = sum(vl_dir_municipal),
    pct_centralizacao_nacional = 100 * vl_dir_nacional / pmax(total_arrecadado, 1),
    custo_por_eleito = if_else(qtd_eleitos > 0, total_arrecadado / qtd_eleitos, NA_real_),
    .groups = "drop"
  ) %>%
  filter(qtd_eleitos >= 20, !is.na(custo_por_eleito))
salvar_tabela(resumo_partido, "04_centralizacao_por_partido.csv")

med_cent <- median(resumo_partido$pct_centralizacao_nacional, na.rm = TRUE)
med_custo <- median(resumo_partido$custo_por_eleito, na.rm = TRUE)

p_quad <- resumo_partido %>%
  mutate(eficiencia = if_else(custo_por_eleito <= med_custo, "Abaixo da mediana de custo/eleito", "Acima da mediana de custo/eleito")) %>%
  ggplot(aes(x = pct_centralizacao_nacional, y = custo_por_eleito, size = qtd_eleitos, color = eficiencia, label = sg_partido)) +
  geom_vline(xintercept = med_cent, linetype = "dashed", color = PALETA$slate, linewidth = 0.6) +
  geom_hline(yintercept = med_custo, linetype = "dashed", color = PALETA$slate, linewidth = 0.6) +
  annotate("text", x = 82, y = max(resumo_partido$custo_por_eleito) * 0.92, label = "Cúpula Cara", hjust = 1, size = 3.5, fontface = "bold", color = PALETA$slate) +
  annotate("text", x = 6, y = min(resumo_partido$custo_por_eleito) * 1.05, label = "Capilar Eficiente", hjust = 0, size = 3.5, fontface = "bold", color = PALETA$esmeralda) +
  geom_point(alpha = 0.85) +
  ggrepel::geom_text_repel(size = 3.2, fontface = "bold", box.padding = 0.45, force = 2.5, min.segment.length = 0, max.overlaps = 35, show.legend = FALSE) +
  scale_color_manual(values = c("Abaixo da mediana de custo/eleito" = PALETA$esmeralda, "Acima da mediana de custo/eleito" = PALETA$azul)) +
  scale_x_continuous(labels = function(x) fmt_pct_br(x, 0)) +
  scale_y_log10(labels = fmt_reais_curto) +
  labs(
    title = "Centralizar recursos em Brasília não garante menor custo por eleito",
    subtitle = "% vindo do Diretório Nacional vs. arrecadação por eleito (partidos >= 20 eleitos)",
    x = "Centralização Nacional (%)",
    y = "Arrecadação por Eleito (escala log)",
    size = "Eleitos",
    color = NULL
  ) +
  tema_slide(base_size = 13)
salvar_grafico(p_quad, "04a_quadrante_centralizacao_partidos.png", width = 11, height = 7)

# Gráfico 4b: Heatmap de alocação regional dos 12 maiores partidos por arrecadação
top12 <- resumo_partido %>% slice_max(total_arrecadado, n = 12) %>% pull(sg_partido)

heat_reg <- df %>%
  filter(sg_partido %in% top12) %>%
  group_by(sg_partido, regiao) %>%
  summarise(arrec = sum(total_arrecadado), vl_nac = sum(vl_dir_nacional), .groups = "drop") %>%
  group_by(sg_partido) %>%
  mutate(pct_regiao_no_partido = 100 * arrec / sum(arrec)) %>%
  ungroup()

p_heat <- ggplot(heat_reg, aes(x = regiao, y = fct_reorder(sg_partido, arrec, .fun = sum), fill = pct_regiao_no_partido)) +
  geom_tile(color = "white") +
  geom_text(aes(label = paste0(round(pct_regiao_no_partido, 1), "%")), size = 3) +
  scale_fill_viridis_c() +
  labs(
    title = "Distribuição Regional da Arrecadação nos 12 Maiores Partidos",
    subtitle = "Proporção (%) dos recursos captados por macrorregião dentro de cada legenda",
    x = "Macrorregião",
    y = "Partido",
    fill = "% Arrecadação"
  ) +
  theme_minimal()
salvar_grafico(p_heat, "04b_heatmap_regional_partidos.png", width = 10, height = 7)
