# ==============================================================================
# ANÁLISE 08: EFEITO DOBRADINHA & PARADOXO DO FORASTEIRO (REGRESSÃO LOGÍSTICA)
# ==============================================================================
# Tese: Controlando por gasto total e porte municipal, receber recursos de outros
# candidatos (dobradinha) eleva a chance de eleição, e ser "forasteiro" ajuda no Centro-Oeste.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [08] Modelo Logístico (Odds Ratio) + Efeito Dobradinha & Localidade ===")

df <- ler_ouro("ouro_eficiencia_anomalias_candidatos.parquet") %>%
  filter(
    ds_cargo %in% c("PREFEITO", "VEREADOR"),
    ds_genero %in% c("FEMININO", "MASCULINO"),
    !is.na(is_candidato_local),
    !is.na(porte_municipio),
    !is.na(idade_2024),
    idade_2024 >= 18, idade_2024 <= 100
  ) %>%
  mutate(
    teve_dobradinha = pct_receita_de_outros_candidatos > 0,
    log_gasto = log1p(total_gasto),
    raca_neg_ind = ds_cor_raca %in% c("PRETA", "PARDA", "INDÍGENA"),
    genero_fem = ds_genero == "FEMININO",
    porte_municipio = fct_relevel(
      porte_municipio,
      "Pequeno Porte I (<20k)", "Pequeno Porte II (20k-50k)",
      "Médio Porte (50k-100k)", "Grande Porte (100k-500k)", "Metrópole (>500k)"
    )
  )

df_ver <- df %>% filter(ds_cargo == "VEREADOR")

mod_ver <- glm(
  is_eleito ~ log_gasto + teve_dobradinha + is_candidato_local + genero_fem + raca_neg_ind + idade_2024 + porte_municipio + regiao,
  data = df_ver,
  family = binomial()
)

# IC 95% via erro padrão de Wald (rápido e exato para n > 400k)
or_tabela <- broom::tidy(mod_ver, conf.int = FALSE) %>%
  filter(term != "(Intercept)") %>%
  mutate(
    odds_ratio = exp(estimate),
    conf.low   = exp(estimate - 1.96 * std.error),
    conf.high  = exp(estimate + 1.96 * std.error)
  ) %>%
  arrange(desc(odds_ratio))
salvar_tabela(or_tabela, "08_odds_ratio_regressao_vereadores.csv")

termos_foco <- or_tabela %>%
  filter(!str_starts(term, "porte_municipio") & !str_starts(term, "regiao")) %>%
  mutate(
    efeito = if_else(odds_ratio >= 1, "Aumenta chance (OR > 1)", "Reduz chance (OR < 1)"),
    rotulo = recode(
      term,
      log_gasto = "Log(1 + Gasto Total)",
      teve_dobradinhaTRUE = "Recebeu de Outro Candidato (Dobradinha)",
      is_candidato_localTRUE = "Candidato Natural da UF (Local)",
      genero_femTRUE = "Gênero Feminino",
      raca_neg_indTRUE = "Cor/Raça Preta, Parda ou Indígena",
      idade_2024 = "Idade (+1 ano)"
    )
  )

p_forest <- ggplot(termos_foco, aes(x = odds_ratio, y = fct_reorder(rotulo, odds_ratio), color = efeito)) +
  geom_vline(xintercept = 1, linetype = "dashed", color = PALETA$slate, linewidth = 0.8) +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high), size = 0.85, linewidth = 1) +
  geom_text(aes(label = paste0(fmt_num_br(odds_ratio, 2), "×")), vjust = -0.9, size = 3.6, fontface = "bold", show.legend = FALSE) +
  scale_color_manual(values = c("Aumenta chance (OR > 1)" = PALETA$esmeralda, "Reduz chance (OR < 1)" = PALETA$carmim)) +
  scale_x_log10(breaks = c(0.3, 0.5, 1.0, 1.5, 2.0), labels = function(x) paste0(fmt_num_br(x, 1), "×")) +
  labs(
    title = "Dobradinha aumenta em 82% a chance de eleição; gênero feminino reduz em 66%",
    subtitle = paste0("Odds Ratios da regressão logística controlada por porte e região (n = ", fmt_int_br(nrow(df_ver)), " vereadores)"),
    x = "Odds Ratio (escala log10, IC 95% | linha tracejada = 1,0× neutro)",
    y = NULL,
    color = NULL
  ) +
  tema_slide(base_size = 13) +
  theme(panel.grid.major.y = element_blank())
salvar_grafico(p_forest, "08a_forest_plot_odds_ratio_vereador.png", width = 11, height = 6.2)

# Gráfico 8b: Paradoxo do Forasteiro entre Prefeitos por Macrorregião
pref_local <- df %>%
  filter(ds_cargo == "PREFEITO") %>%
  group_by(regiao, is_candidato_local) %>%
  summarise(
    qtd = n(),
    taxa_eleicao_pct = 100 * mean(is_eleito),
    .groups = "drop"
  ) %>%
  mutate(origem = if_else(is_candidato_local, "Natural da UF (Local)", "Nascido Fora da UF (Forasteiro)"))
salvar_tabela(pref_local, "08_paradoxo_forasteiro_prefeitos.csv")

p_inter <- ggplot(pref_local, aes(x = regiao, y = taxa_eleicao_pct, group = origem, color = origem)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  labs(
    title = "O Paradoxo do 'Forasteiro': Taxa de Eleição de Prefeitos por Origem e Região",
    subtitle = "No Centro-Oeste a taxa dos nascidos fora da UF supera a dos locais, ao contrário de Sul e Sudeste",
    x = "Macrorregião",
    y = "Taxa de Eleição (%)",
    color = "Naturalidade"
  ) +
  theme_minimal()
salvar_grafico(p_inter, "08b_interacao_local_forasteiro_prefeitos.png", width = 10, height = 6.5)
