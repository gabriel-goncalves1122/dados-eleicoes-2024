# ==============================================================================
# ANÁLISE 05: A INDÚSTRIA INVISÍVEL BIPARTIDÁRIA DOS FORNECEDORES
# ==============================================================================
# Tese: Um núcleo pequeno (2.337 fornecedores em >=10 municípios) captura 31.9%
# do mercado multi-candidato e presta serviços para uma média de 11.6 partidos.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [05] Concentração de Mercado e Rede Multipartidária de Fornecedores ===")

df <- ler_ouro("ouro_fornecedores_rede.parquet") %>%
  arrange(valor_total_contratado) %>%
  mutate(
    prop_forn = row_number() / n(),
    prop_valor = cumsum(valor_total_contratado) / sum(valor_total_contratado)
  )

# Coeficiente de Gini via regra do trapézio na curva de Lorenz
n <- nrow(df)
x <- c(0, df$prop_forn)
y <- c(0, df$prop_valor)
gini <- 1 - sum((x[-1] - x[-length(x)]) * (y[-1] + y[-length(y)]))

resumo_forn <- df %>%
  group_by(flag_rede_multi_municipio) %>%
  summarise(
    qtd_fornecedores = n(),
    valor_total_mi = sum(valor_total_contratado) / 1e6,
    media_partidos = mean(qtd_partidos),
    mediana_municipios = median(qtd_municipios),
    gini_mercado_geral = gini,
    .groups = "drop"
  )
salvar_tabela(resumo_forn, "05_concentracao_fornecedores_gini.csv")

# Amostra uniforme na curva para plot leve em PNG
idx <- unique(round(seq(1, n, length.out = 4000)))
p_lorenz <- ggplot(df[idx, ], aes(x = prop_forn * 100, y = prop_valor * 100)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray40") +
  geom_area(alpha = 0.25, fill = "steelblue") +
  geom_line(color = "steelblue", linewidth = 1) +
  annotate("text", x = 25, y = 78, label = paste0("Gini = ", round(gini, 3), "\n(N = ", n, " fornecedores >=2 cand.)"), size = 4) +
  labs(
    title = "Curva de Lorenz: Concentração do Mercado de Fornecedores Eleitorais (2024)",
    subtitle = "Distribuição acumulada de faturamento contratado entre prestadores com 2+ candidatos",
    x = "% Acumulado de Fornecedores (do menor para o maior)",
    y = "% Acumulado do Faturamento Total"
  ) +
  theme_minimal()
salvar_grafico(p_lorenz, "05a_curva_lorenz_fornecedores.png", width = 10, height = 6.5)

# Gráfico 5b: Alcance Territorial vs. Capilaridade Partidária
p_rede <- df %>%
  filter(qtd_municipios >= 3) %>%
  ggplot(aes(x = qtd_municipios, y = qtd_partidos, color = macro_categoria_principal, size = valor_total_contratado / 1e6)) +
  geom_point(alpha = 0.45) +
  geom_vline(xintercept = 10, linetype = "dashed") +
  scale_x_log10() +
  labs(
    title = "Fornecedores Intermunicipais: Alcance Territorial vs. Partidos Atendidos",
    subtitle = "Prestadores com >=3 municípios atendidos (linha vertical marca corte de 10+ municípios)",
    x = "Municípios Atendidos (escala log10)",
    y = "Partidos Distintos Atendidos",
    color = "Macro-categoria",
    size = "Faturamento (R$ M)"
  ) +
  theme_minimal()
salvar_grafico(p_rede, "05b_rede_fornecedores_multipartido.png", width = 11, height = 7)
