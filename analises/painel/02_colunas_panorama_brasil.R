# ==============================================================================
# PAINEL 02: COLUNAS E BARRAS DE PANORAMA BRASIL (B1, B2, B5, B6, B7, B8)
# ==============================================================================

if (file.exists("analises/painel/_helpers_painel.R")) {
  source("analises/painel/_helpers_painel.R")
} else {
  source("_helpers_painel.R")
}

message("=== [Painel 02] Gerando Barras/Colunas de Panorama (B1, B2, B5, B6, B7, B8) ===")

part_df <- ler_ouro("ouro_centralizacao_partidaria.parquet")
cand_df <- ler_ouro("ouro_eficiencia_anomalias_candidatos.parquet")
pca_df  <- ler_ouro("ouro_pca_municipios.parquet")

# --- B1: Top 15 partidos em nº de eleitos ---
b1_df <- part_df %>%
  group_by(sg_partido) %>%
  summarise(eleitos = sum(qtd_eleitos, na.rm = TRUE), .groups = "drop") %>%
  slice_max(eleitos, n = 15)

p_b1 <- ggplot(b1_df, aes(x = eleitos, y = fct_reorder(sg_partido, eleitos))) +
  geom_col() +
  geom_text(aes(label = format(eleitos, big.mark = ".")), hjust = -0.1, size = 3.2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.14))) +
  labs(title = "B1 · Top 15 Partidos em Número de Eleitos (Brasil 2024)", x = "Total de Eleitos (Prefeitos + Vereadores)", y = NULL) +
  theme_minimal()
salvar_fig(p_b1, "b1_top15_partidos_eleitos.png", width = 10, height = 6)

# --- B2: Top 15 partidos em total arrecadado (R$ milhões) ---
b2_df <- part_df %>%
  group_by(sg_partido) %>%
  summarise(mi_arrec = sum(total_arrecadado, na.rm = TRUE) / 1e6, .groups = "drop") %>%
  slice_max(mi_arrec, n = 15)

p_b2 <- ggplot(b2_df, aes(x = mi_arrec, y = fct_reorder(sg_partido, mi_arrec))) +
  geom_col() +
  geom_text(aes(label = paste0("R$ ", round(mi_arrec, 1), "M")), hjust = -0.1, size = 3.2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.16))) +
  labs(title = "B2 · Top 15 Partidos em Total Arrecadado (Brasil 2024)", x = "Arrecadação Total (R$ Milhões)", y = NULL) +
  theme_minimal()
salvar_fig(p_b2, "b2_top15_partidos_arrecadacao.png", width = 10, height = 6)

# --- B5 + B6 Unificado: % de Mulheres vs. Negros e Indígenas Eleitos por Região ---
b5_b6_df <- cand_df %>%
  filter(is_eleito, !is.na(regiao)) %>%
  group_by(regiao) %>%
  summarise(
    `Mulheres Eleitas` = 100 * mean(ds_genero == "FEMININO", na.rm = TRUE),
    `Negros e Indígenas Eleitos` = 100 * mean(ds_cor_raca %in% c("PRETA", "PARDA", "INDÍGENA"), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-regiao, names_to = "grupo", values_to = "pct") %>%
  mutate(grupo = factor(grupo, levels = c("Mulheres Eleitas", "Negros e Indígenas Eleitos")))

p_b5_b6 <- ggplot(b5_b6_df, aes(x = pct, y = fct_reorder(regiao, pct, .fun = max), fill = grupo)) +
  geom_col(position = position_dodge(width = 0.76), width = 0.70) +
  geom_text(
    aes(label = fmt_pct_br(pct, 1)),
    position = position_dodge(width = 0.76),
    hjust = -0.12,
    size = 3.5,
    fontface = "bold",
    color = "#1e293b"
  ) +
  scale_fill_manual(values = c("Negros e Indígenas Eleitos" = PALETA$esmeralda, "Mulheres Eleitas" = PALETA$azul)) +
  guides(fill = guide_legend(reverse = TRUE)) +
  scale_x_continuous(labels = function(x) fmt_pct_br(x, 0), expand = expansion(mult = c(0, 0.14))) +
  labs(
    title = "Sudeste e Sul concentram os menores percentuais de mulheres e negros eleitos",
    subtitle = "Participação sobre o total de eleitos (prefeitos + vereadores) em cada macrorregião",
    x = "Participação entre os Eleitos (%)",
    y = NULL,
    fill = NULL
  ) +
  tema_slide(base_size = 13) +
  theme(panel.grid.major.y = element_blank())
salvar_fig(p_b5_b6, "b5_b6_mulheres_vs_negros_indigenas_regiao.png", width = 10, height = 6)

# --- B7: Escolaridade dos prefeitos eleitos ---
b7_df <- pca_df %>%
  filter(!is.na(prefeito_eleito_instrucao)) %>%
  count(prefeito_eleito_instrucao, name = "qtd") %>%
  mutate(pct = 100 * qtd / sum(qtd))

p_b7 <- ggplot(b7_df, aes(x = qtd, y = fct_reorder(prefeito_eleito_instrucao, qtd))) +
  geom_col() +
  geom_text(aes(label = paste0(format(qtd, big.mark = "."), " (", round(pct, 1), "%)")), hjust = -0.08, size = 3.2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.22))) +
  labs(title = "B7 · Escolaridade dos Prefeitos Eleitos no Brasil (2024)", x = "Nº de Municípios", y = NULL) +
  theme_minimal()
salvar_fig(p_b7, "b7_escolaridade_prefeitos.png", width = 11, height = 6)

# --- B8: Distribuição etária (% Candidatos vs. % Eleitos) ---
b8_base <- cand_df %>%
  filter(!is.na(idade_2024), idade_2024 >= 18, idade_2024 <= 99) %>%
  mutate(
    faixa_idade = cut(
      idade_2024,
      breaks = c(17, 29, 39, 49, 59, 69, 100),
      labels = c("18–29", "30–39", "40–49", "50–59", "60–69", "70+")
    )
  )

b8_df <- bind_rows(
  b8_base %>% count(faixa_idade) %>% mutate(grupo = "Todos os Candidatos", pct = 100 * n / sum(n)),
  b8_base %>% filter(is_eleito) %>% count(faixa_idade) %>% mutate(grupo = "Eleitos", pct = 100 * n / sum(n))
)

p_b8 <- ggplot(b8_df, aes(x = faixa_idade, y = pct, fill = grupo)) +
  geom_col(position = "dodge") +
  labs(
    title = "B8 · Distribuição Etária: Candidatos vs. Eleitos (Brasil 2024)",
    x = "Faixa Etária (anos)",
    y = "Participação (% dentro do grupo)",
    fill = NULL
  ) +
  theme_minimal()
salvar_fig(p_b8, "b8_faixa_etaria_cand_vs_eleitos.png", width = 10, height = 6)
