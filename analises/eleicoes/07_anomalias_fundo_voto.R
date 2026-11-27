# ==============================================================================
# ANÁLISE 07: QUADRANTE DAS ANOMALIAS (ALTO FUNDO PÚBLICO X QUASE ZERO VOTO)
# ==============================================================================
# Tese: 2.217 candidaturas receberam >= R$ 10k e tiveram <= 10 votos, com forte
# concentração entre mulheres (1.250 candidatas, R$ 34,21M de fundo público).

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [07] Anomalias Eleitorais: Alto Recurso x Baixa Votação ===")

df <- ler_ouro("ouro_eficiencia_anomalias_candidatos.parquet") %>%
  filter(ds_cargo %in% c("PREFEITO", "VEREADOR"), ds_genero %in% c("FEMININO", "MASCULINO"))

resumo_anomalia <- df %>%
  filter(flag_anomalia_voto_recurso) %>%
  group_by(regiao, ds_genero) %>%
  summarise(
    qtd_anomalias = n(),
    mi_arrecadado = sum(total_arrecadado) / 1e6,
    mi_fundo_publico = sum(total_fundo_publico) / 1e6,
    .groups = "drop"
  )
salvar_tabela(resumo_anomalia, "07_anomalias_por_regiao_genero.csv")

# Gráfico 7a: Log-Log 2D Density (Fundo Público vs. Votos) com quadrante de anomalia
p_loglog <- df %>%
  filter(total_fundo_publico > 0) %>%
  ggplot(aes(x = total_fundo_publico + 1, y = total_votos + 1)) +
  geom_bin2d(bins = 45) +
  annotate("rect", xmin = 10001, xmax = Inf, ymin = 1, ymax = 11, fill = NA, color = "red", linewidth = 0.9, linetype = "dashed") +
  facet_wrap(~ds_cargo) +
  scale_x_log10(labels = label_dollar(prefix = "R$ ", big.mark = ".")) +
  scale_y_log10(labels = label_number(big.mark = ".")) +
  scale_fill_viridis_c(trans = "log10") +
  labs(
    title = "Mapa Log-Log de Eficiência: Fundo Público vs. Votos Nominais",
    subtitle = "Retângulo tracejado destaca o quadrante de anomalias (Fundo >= R$ 10k e <= 10 votos)",
    x = "Fundo Público Recebido + 1 (escala log10)",
    y = "Votos Nominais + 1 (escala log10)",
    fill = "Candidatos"
  ) +
  theme_minimal()
salvar_grafico(p_loglog, "07a_anomalia_fundo_voto_loglog.png", width = 12, height = 6.5)

# Gráfico 7b: Cleveland Dumbbell comparando taxa de anomalias M vs F nos 15 maiores partidos
partidos_top15 <- df %>% count(sg_partido) %>% slice_max(n, n = 15) %>% pull(sg_partido)

taxa_part <- df %>%
  filter(sg_partido %in% partidos_top15) %>%
  group_by(sg_partido, ds_genero) %>%
  summarise(taxa_anomalia_pct = 100 * mean(flag_anomalia_voto_recurso), .groups = "drop") %>%
  pivot_wider(names_from = ds_genero, values_from = taxa_anomalia_pct) %>%
  mutate(sg_partido = fct_reorder(sg_partido, FEMININO))

p_dumb <- ggplot(taxa_part) +
  geom_segment(aes(x = MASCULINO, xend = FEMININO, y = sg_partido, yend = sg_partido), color = "gray60", linewidth = 0.8) +
  geom_point(aes(x = MASCULINO, y = sg_partido, color = "Masculino"), size = 3) +
  geom_point(aes(x = FEMININO, y = sg_partido, color = "Feminino"), size = 3) +
  labs(
    title = "Taxa de Candidaturas com Alto Recurso (>=R$10k) e <=10 Votos por Partido e Gênero",
    subtitle = "15 maiores partidos em número de candidaturas (Brasil 2024)",
    x = "% de Candidaturas no Quadrante de Anomalia",
    y = "Partido",
    color = "Gênero"
  ) +
  theme_minimal()
salvar_grafico(p_dumb, "07b_dumbbell_anomalias_partido_genero.png", width = 10, height = 7)
