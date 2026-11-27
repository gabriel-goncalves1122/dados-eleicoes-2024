# ==============================================================================
# PAINEL 05: RANKINGS EXECUTIVOS (R1: TOP 10 FORNECEDORES | R2: EXTREMOS MUNICIPAIS)
# ==============================================================================

if (file.exists("analises/painel/_helpers_painel.R")) {
  source("analises/painel/_helpers_painel.R")
} else {
  source("_helpers_painel.R")
}

message("=== [Painel 05] Gerando Rankings Executivos (R1 e R2) ===")

forn_df <- ler_ouro("ouro_fornecedores_rede.parquet")
pca_df  <- ler_ouro("ouro_pca_municipios.parquet")

# --- R1: Top 10 Fornecedores do Brasil ---
r1_df <- forn_df %>%
  slice_max(valor_total_contratado, n = 10) %>%
  transmute(
    nome_fornecedor = nm_fornecedor,
    cnae_principal = ds_cnae_fornecedor,
    macro_categoria = macro_categoria_principal,
    qtd_municipios,
    qtd_partidos,
    valor_total_mi = round(valor_total_contratado / 1e6, 2)
  )
salvar_tab(r1_df, "r1_top10_fornecedores.csv")

p_r1 <- r1_df %>%
  mutate(
    nome_limpo = str_squish(str_remove(nome_fornecedor, "\\s+(LTDA|S\\.A\\.|SPE LTDA)$")),
    nome_limpo = str_trunc(nome_limpo, 34),
    eh_digital = if_else(macro_categoria == "Impulsionamento Digital", "Impulsionamento Digital", "Demais Setores"),
    rotulo_val = paste0(fmt_reais_curto(valor_total_mi * 1e6), "  (", fmt_int_br(qtd_municipios), " mun. | ", qtd_partidos, " part.)")
  ) %>%
  ggplot(aes(x = valor_total_mi, y = fct_reorder(nome_limpo, valor_total_mi), fill = eh_digital)) +
  geom_col(width = 0.72) +
  geom_text(aes(label = rotulo_val), hjust = -0.06, size = 3.2, fontface = "bold", color = "#1e293b") +
  scale_fill_manual(values = c("Impulsionamento Digital" = PALETA$azul, "Demais Setores" = PALETA$slate_claro)) +
  scale_x_continuous(labels = function(x) paste0("R$ ", fmt_int_br(x), "M"), expand = expansion(mult = c(0, 0.42))) +
  labs(
    title = "Big Techs e meios de pagamento lideram faturamento atendendo quase todos os partidos",
    subtitle = "Top 10 maiores fornecedores eleitorais do Brasil (2024) com alcance municipal e partidário",
    x = "Faturamento Contratado (R$ Milhões)",
    y = NULL,
    fill = NULL
  ) +
  tema_slide(base_size = 13) +
  theme(panel.grid.major.y = element_blank())
salvar_fig(p_r1, "r1_top10_fornecedores.png", width = 11.5, height = 6)

# --- R2: Top 10 Municípios Mais Caros e Mais Baratos por Habitante ---
mun_validos <- pca_df %>%
  filter(!is.na(gasto_campanha_per_capita), gasto_campanha_per_capita > 0)

r2_caros <- mun_validos %>%
  slice_max(gasto_campanha_per_capita, n = 10) %>%
  mutate(grupo = "10 Mais Caros por Habitante")

r2_baratos <- mun_validos %>%
  slice_min(gasto_campanha_per_capita, n = 10) %>%
  mutate(grupo = "10 Mais Baratos por Habitante")

r2_df <- bind_rows(r2_caros, r2_baratos) %>%
  select(grupo, sg_uf, nm_municipio, porte_municipio, gasto_campanha_per_capita, custo_medio_voto_municipio)
salvar_tab(r2_df, "r2_extremos_municipios_custo.csv")

p_r2 <- r2_df %>%
  mutate(rotulo = paste0(nm_municipio, " (", sg_uf, ")")) %>%
  ggplot(aes(x = gasto_campanha_per_capita, y = fct_reorder(rotulo, gasto_campanha_per_capita))) +
  geom_col() +
  facet_wrap(~grupo, scales = "free") +
  labs(
    title = "R2 · Extremos Municipais de Custo Eleitoral por Habitante (Brasil 2024)",
    x = "Gasto Total de Campanha per Capita (R$ / hab.)",
    y = NULL
  ) +
  theme_minimal()
salvar_fig(p_r2, "r2_extremos_municipios_custo.png", width = 12, height = 6)
