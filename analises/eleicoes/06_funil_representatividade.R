# ==============================================================================
# ANÁLISE 06: O FUNIL DA SUB-REPRESENTAÇÃO (CENSO -> COTA -> FUNDO -> URNA)
# ==============================================================================
# Tese: A cota formal (~34% de candidaturas femininas) é cumprida em todo o país,
# mas a conversão do fundo público e em cadeiras eleitas cai de forma desigual.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [06] Funil da Sub-representação (Censo -> Cota -> Fundo -> Urna) ===")

df <- ler_ouro("ouro_representatividade_municipal.parquet") %>%
  filter(!is.na(regiao))

funil_regiao <- df %>%
  group_by(regiao) %>%
  summarise(
    mulheres_censo = mean(pct_mulheres_censo, na.rm = TRUE),
    mulheres_cand  = mean(pct_cand_mulheres, na.rm = TRUE),
    mulheres_fundo = mean(pct_fundo_publico_mulheres, na.rm = TRUE),
    mulheres_eleit = mean(pct_eleitos_mulheres, na.rm = TRUE),
    neg_ind_censo  = mean(pct_negros_indigenas_censo, na.rm = TRUE),
    neg_ind_cand   = mean(pct_cand_negros_indigenas, na.rm = TRUE),
    neg_ind_fundo  = mean(pct_fundo_publico_negros_indigenas, na.rm = TRUE),
    neg_ind_eleit  = mean(pct_eleitos_negros_indigenas, na.rm = TRUE),
    med_gap_fin_mulheres = median(gap_financiamento_mulheres, na.rm = TRUE),
    .groups = "drop"
  )
salvar_tabela(funil_regiao, "06_funil_representatividade_regiao.csv")

funil_long <- funil_regiao %>%
  select(-med_gap_fin_mulheres) %>%
  pivot_longer(-regiao, names_to = "chave", values_to = "pct") %>%
  separate(chave, into = c("grupo", "estagio"), sep = "_(?=[^_]+$)") %>%
  mutate(
    grupo = if_else(grupo == "mulheres", "Mulheres", "Negros e Indígenas"),
    estagio = recode(
      estagio,
      censo = "1. População Censo",
      cand  = "2. Candidaturas",
      fundo = "3. Fundo Público",
      eleit = "4. Eleitos"
    ),
    estagio = factor(estagio, levels = c("1. População Censo", "2. Candidaturas", "3. Fundo Público", "4. Eleitos"))
  )

cores_reg <- c(
  "Nordeste"     = PALETA$esmeralda,
  "Norte"        = PALETA$azul,
  "Centro-Oeste" = PALETA$slate,
  "Sul"          = PALETA$ambar,
  "Sudeste"      = PALETA$carmim
)

rotulos_ext <- funil_long %>%
  filter(estagio %in% c("1. População Censo", "4. Eleitos"))

p_slope <- ggplot(funil_long, aes(x = estagio, y = pct, group = regiao, color = regiao)) +
  geom_line(linewidth = 1.15, alpha = 0.9) +
  geom_point(size = 2.8) +
  ggrepel::geom_text_repel(
    data = rotulos_ext,
    aes(label = fmt_pct_br(pct, 1)),
    size = 3.0, fontface = "bold", direction = "y", box.padding = 0.15,
    min.segment.length = 1, show.legend = FALSE
  ) +
  facet_wrap(~grupo) +
  scale_color_manual(values = cores_reg) +
  scale_y_continuous(labels = function(x) fmt_pct_br(x, 0)) +
  guides(color = guide_legend(nrow = 1)) +
  labs(
    title = "Cota de ~34% não chega ao caixa nem à urna — perda máxima no Sudeste",
    subtitle = "Média municipal em 4 estágios: Censo 2022 → Candidaturas → Fundo Público → Eleitos",
    x = NULL,
    y = "Participação Média (%)",
    color = NULL
  ) +
  tema_slide(base_size = 13) +
  theme(axis.text.x = element_text(angle = 16, hjust = 1))
salvar_grafico(p_slope, "06a_funil_representatividade_slopegraph.png", width = 11.5, height = 6.5)

# Gráfico 6b: Distribuição municipal do gap de financiamento feminino
p_gap <- df %>%
  filter(!is.na(gap_financiamento_mulheres)) %>%
  ggplot(aes(x = gap_financiamento_mulheres, fill = regiao)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  facet_wrap(~regiao, ncol = 1, scales = "free_y") +
  labs(
    title = "Ilusão da Cota vs. Dinheiro Real: Gap de Financiamento Feminino por Município",
    subtitle = "Diferença (% Fundo Público às mulheres - % Candidatas mulheres). Valores < 0 indicam subfinanciamento.",
    x = "Gap de Financiamento (pontos percentuais)",
    y = "Densidade"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
salvar_grafico(p_gap, "06b_densidade_gap_financiamento_mulheres.png", width = 10, height = 8)
