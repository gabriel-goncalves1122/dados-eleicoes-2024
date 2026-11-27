# ==============================================================================
# ANÁLISE 03: CUSTO REGRESSIVO DA BUROCRACIA VS. ESCALADA DIGITAL
# ==============================================================================
# Tese: Jurídico + Contábil somam mais que 2x todo o Digital e pesam 20.6% nas
# cidades <20k vs. 5.9% nas metrópoles, enquanto o Digital cresce 8.4x com o porte.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [03] Estrutura de Gastos: Burocracia Regressiva vs. Digital ===")

df <- ler_ouro("ouro_estrutura_gastos_campanha.parquet") %>%
  filter(!is.na(porte_municipio)) %>%
  mutate(
    porte_municipio = fct_relevel(
      porte_municipio,
      "Pequeno Porte I (<20k)", "Pequeno Porte II (20k-50k)",
      "Médio Porte (50k-100k)", "Grande Porte (100k-500k)", "Metrópole (>500k)"
    )
  )

mix_porte <- df %>%
  group_by(porte_municipio, macro_categoria_despesa) %>%
  summarise(total = sum(total_despesa), .groups = "drop") %>%
  group_by(porte_municipio) %>%
  mutate(
    total_porte = sum(total),
    pct = 100 * total / total_porte
  ) %>%
  ungroup()
salvar_tabela(mix_porte, "03_mix_gastos_por_porte.csv")

# Gráfico 3a: Marimekko (Mosaic com largura proporcional ao volume financeiro por porte)
ordem_cats <- mix_porte %>%
  group_by(macro_categoria_despesa) %>%
  summarise(tot = sum(total), .groups = "drop") %>%
  arrange(desc(tot)) %>%
  pull(macro_categoria_despesa)

marimekko <- mix_porte %>%
  mutate(macro_categoria_despesa = factor(macro_categoria_despesa, levels = ordem_cats)) %>%
  arrange(porte_municipio, macro_categoria_despesa) %>%
  group_by(porte_municipio) %>%
  mutate(
    ymax = cumsum(pct),
    ymin = ymax - pct
  ) %>%
  ungroup() %>%
  left_join(
    mix_porte %>%
      distinct(porte_municipio, total_porte) %>%
      arrange(porte_municipio) %>%
      mutate(
        xmax = cumsum(total_porte) / 1e9,
        xmin = xmax - total_porte / 1e9,
        xmid = (xmin + xmax) / 2
      ),
    by = c("porte_municipio", "total_porte")
  )

rotulos_x <- marimekko %>% distinct(porte_municipio, xmid, total_porte)

p_marimekko <- ggplot(marimekko) +
  geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = macro_categoria_despesa),
            color = "white", linewidth = 0.4) +
  scale_x_continuous(breaks = rotulos_x$xmid, labels = paste0(rotulos_x$porte_municipio, "\n(R$ ", round(rotulos_x$total_porte / 1e9, 2), " bi)")) +
  labs(
    title = "Composição de Custos da Campanha por Porte Municipal (Marimekko)",
    subtitle = "Largura da coluna = volume gasto (R$ bi) | Altura = participação (%) de cada categoria",
    x = "Porte do Município (largura proporcional ao gasto agregado)",
    y = "Participação no Orçamento (%)",
    fill = "Macro-categoria"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 8))
salvar_grafico(p_marimekko, "03a_marimekko_estrutura_gastos.png", width = 12, height = 7)

# Gráfico 3b: Curva semanal de desembolso (Eleitos vs. Não Eleitos por macro-categoria)
curva_sem <- df %>%
  filter(!is.na(semana_eleicao), semana_eleicao >= as.Date("2024-08-01"), semana_eleicao <= as.Date("2024-11-15")) %>%
  group_by(semana_eleicao, is_eleito, macro_categoria_despesa) %>%
  summarise(valor = sum(total_despesa) / 1e6, .groups = "drop") %>%
  mutate(status = if_else(is_eleito, "Eleitos", "Não Eleitos"))

p_curva <- ggplot(curva_sem, aes(x = semana_eleicao, y = valor, color = status)) +
  geom_line(linewidth = 0.9) +
  facet_wrap(~macro_categoria_despesa, scales = "free_y") +
  labs(
    title = "Dinâmica Semanal das Despesas de Campanha (Eleitos vs. Não Eleitos)",
    subtitle = "Volume contratado por semana entre agosto e novembro de 2024 (R$ milhões)",
    x = "Semana",
    y = "Despesa Contratada (R$ Milhões)",
    color = "Resultado"
  ) +
  theme_minimal()
salvar_grafico(p_curva, "03b_curva_semanal_despesas.png", width = 12, height = 7)
