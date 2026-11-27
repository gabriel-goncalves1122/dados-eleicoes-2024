# ==============================================================================
# PAINEL 04: SÉRIES TEMPORAIS DE CAMPANHA (T1, T2, T3, T6)
# ==============================================================================

if (file.exists("analises/painel/_helpers_painel.R")) {
  source("analises/painel/_helpers_painel.R")
} else {
  source("_helpers_painel.R")
}

message("=== [Painel 04] Gerando Séries Temporais (T1, T2, T3, T6) ===")

gast_df <- ler_ouro("ouro_estrutura_gastos_campanha.parquet") %>%
  filter(!is.na(semana_eleicao), semana_eleicao >= as.Date("2024-08-01"), semana_eleicao <= as.Date("2024-11-15"))

# --- T1: Evolução semanal do gasto total no Brasil ---
t1_df <- gast_df %>%
  group_by(semana_eleicao) %>%
  summarise(mi_despesa = sum(total_despesa, na.rm = TRUE) / 1e6, .groups = "drop")

p_t1 <- ggplot(t1_df, aes(x = semana_eleicao, y = mi_despesa)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = as.Date("2024-10-06"), linetype = "dashed", color = "red") +
  geom_vline(xintercept = as.Date("2024-10-27"), linetype = "dashed", color = "blue") +
  labs(
    title = "T1 · Evolução Semanal das Despesas de Campanha (Brasil 2024)",
    subtitle = "Linhas tracejadas marcam o 1º turno (06/10) e o 2º turno (27/10)",
    x = "Semana",
    y = "Despesa Contratada (R$ Milhões)"
  ) +
  theme_minimal()
salvar_fig(p_t1, "t1_evolucao_semanal_gastos.png", width = 10, height = 5.8)

# --- T2: Ritmo semanal Eleitos vs. Não Eleitos ---
t2_df <- gast_df %>%
  group_by(semana_eleicao, is_eleito) %>%
  summarise(mi_despesa = sum(total_despesa, na.rm = TRUE) / 1e6, .groups = "drop") %>%
  mutate(grupo = if_else(is_eleito, "Eleitos", "Não Eleitos"))

p_t2 <- ggplot(t2_df, aes(x = semana_eleicao, y = mi_despesa, color = grupo)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.8) +
  labs(
    title = "T2 · Ritmo Semanal de Gastos: Eleitos vs. Não Eleitos",
    x = "Semana",
    y = "Despesa Contratada (R$ Milhões)",
    color = NULL
  ) +
  theme_minimal()
salvar_fig(p_t2, "t2_ritmo_eleitos_vs_naoeleitos.png", width = 10, height = 5.8)

# --- T3: Corrida semanal Papel/Adesivos vs. Militância vs. Impulsionamento Digital ---
cats_t3 <- c("Papel e Adesivos", "Militância e Pessoal", "Impulsionamento Digital")
t3_df <- gast_df %>%
  filter(macro_categoria_despesa %in% cats_t3) %>%
  group_by(semana_eleicao, macro_categoria_despesa) %>%
  summarise(mi_despesa = sum(total_despesa, na.rm = TRUE) / 1e6, .groups = "drop")

p_t3 <- ggplot(t3_df, aes(x = semana_eleicao, y = mi_despesa, color = macro_categoria_despesa)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.8) +
  labs(
    title = "T3 · Corrida Semanal: Papel/Adesivos vs. Militância vs. Digital",
    x = "Semana",
    y = "Despesa Contratada (R$ Milhões)",
    color = "Macro-categoria"
  ) +
  theme_minimal()
salvar_fig(p_t3, "t3_corrida_papel_militancia_digital.png", width = 10, height = 5.8)

# --- T6: Fluxo de Caixa Semanal (Receitas vs. Despesas direto da Prata via DuckDB) ---
con <- dbConnect(duckdb::duckdb())
t6_df <- tryCatch({
  dbGetQuery(con, sprintf("
    WITH rec AS (
      SELECT DATE_TRUNC('week', dt_receita)::DATE AS semana, SUM(vr_receita)/1e6 AS mi_valor, 'Receitas (Entradas)' AS fluxo
      FROM read_parquet('%s')
      WHERE dt_receita BETWEEN DATE '2024-08-01' AND DATE '2024-11-15'
      GROUP BY 1
    ),
    desp AS (
      SELECT DATE_TRUNC('week', dt_despesa)::DATE AS semana, SUM(vr_despesa_contratada)/1e6 AS mi_valor, 'Despesas (Saídas)' AS fluxo
      FROM read_parquet('%s')
      WHERE dt_despesa BETWEEN DATE '2024-08-01' AND DATE '2024-11-15'
      GROUP BY 1
    )
    SELECT * FROM rec UNION ALL SELECT * FROM desp ORDER BY 1, 3
  ", prata_sql("fato_receitas.parquet"), prata_sql("fato_despesas.parquet")))
}, finally = dbDisconnect(con, shutdown = TRUE))

salvar_tab(t6_df, "t6_fluxo_semanal_receitas_despesas.csv")

t6_plot <- t6_df %>%
  mutate(
    semana = as.Date(semana),
    fluxo = factor(fluxo, levels = c("Receitas (Entradas)", "Despesas (Saídas)"))
  )

p_t6 <- ggplot(t6_plot, aes(x = semana, y = mi_valor, color = fluxo, fill = fluxo)) +
  geom_area(alpha = 0.08, position = "identity") +
  geom_line(linewidth = 1.15) +
  geom_point(size = 2.2) +
  geom_vline(xintercept = as.Date("2024-10-06"), linetype = "dashed", color = PALETA$grafite, linewidth = 0.6) +
  geom_vline(xintercept = as.Date("2024-10-27"), linetype = "dashed", color = PALETA$slate, linewidth = 0.6) +
  annotate("text", x = as.Date("2024-10-06"), y = 1720, label = "1º Turno", hjust = -0.1, size = 3.2, fontface = "bold", color = PALETA$grafite) +
  annotate("text", x = as.Date("2024-10-27"), y = 1720, label = "2º Turno", hjust = -0.1, size = 3.2, fontface = "bold", color = PALETA$slate) +
  scale_color_manual(values = c("Receitas (Entradas)" = PALETA$esmeralda, "Despesas (Saídas)" = PALETA$carmim)) +
  scale_fill_manual(values = c("Receitas (Entradas)" = PALETA$esmeralda, "Despesas (Saídas)" = PALETA$carmim)) +
  scale_x_date(date_breaks = "2 weeks", date_labels = "%d/%m") +
  scale_y_continuous(labels = function(x) fmt_reais_curto(x * 1e6), expand = expansion(mult = c(0.02, 0.10))) +
  labs(
    title = "Despesas explodem antes dos repasses em agosto; caixa estabiliza em setembro",
    subtitle = "Fluxo semanal de receitas (entradas) vs. despesas contratadas (saídas) entre ago. e nov. de 2024",
    x = "Semana (2024)",
    y = "Volume Semanal",
    color = NULL,
    fill = NULL
  ) +
  tema_slide(base_size = 13)
salvar_fig(p_t6, "t6_fluxo_caixa_receitas_vs_despesas.png", width = 10, height = 6)
