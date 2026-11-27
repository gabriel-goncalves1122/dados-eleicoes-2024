# ==============================================================================
# PAINEL 03: COLUNAS E BARRAS DE INSIGHTS MENOS ÓBVIOS (B9, B12, B14, B16, B18)
# ==============================================================================

if (file.exists("analises/painel/_helpers_painel.R")) {
  source("analises/painel/_helpers_painel.R")
} else {
  source("_helpers_painel.R")
}

message("=== [Painel 03] Gerando Barras/Colunas Analíticas (B9, B12, B14, B16, B18) ===")

gast_df <- ler_ouro("ouro_estrutura_gastos_campanha.parquet")
cand_df <- ler_ouro("ouro_eficiencia_anomalias_candidatos.parquet")
part_df <- ler_ouro("ouro_centralizacao_partidaria.parquet")
pca_df  <- ler_ouro("ouro_pca_municipios.parquet")
forn_df <- ler_ouro("ouro_fornecedores_rede.parquet")

# --- B9: Digital vs. Jurídico/Contábil por Porte Municipal ---
b9_df <- gast_df %>%
  filter(!is.na(porte_municipio)) %>%
  group_by(porte_municipio) %>%
  summarise(
    tot = sum(total_despesa),
    `Impulsionamento Digital` = 100 * sum(total_despesa[macro_categoria_despesa == "Impulsionamento Digital"]) / tot,
    `Jurídico e Contábil`     = 100 * sum(total_despesa[macro_categoria_despesa == "Jurídico e Contábil"]) / tot,
    .groups = "drop"
  ) %>%
  select(-tot) %>%
  pivot_longer(-porte_municipio, names_to = "categoria", values_to = "pct") %>%
  mutate(
    categoria = factor(categoria, levels = c("Jurídico e Contábil", "Impulsionamento Digital")),
    porte_municipio = fct_relevel(
      porte_municipio,
      "Pequeno Porte I (<20k)", "Pequeno Porte II (20k-50k)",
      "Médio Porte (50k-100k)", "Grande Porte (100k-500k)", "Metrópole (>500k)"
    )
  )

p_b9 <- ggplot(b9_df, aes(x = porte_municipio, y = pct, fill = categoria)) +
  geom_col(position = position_dodge(width = 0.78), width = 0.72) +
  geom_text(
    aes(label = fmt_pct_br(pct, 1)),
    position = position_dodge(width = 0.78),
    vjust = -0.4,
    size = 3.5,
    fontface = "bold",
    color = "#1e293b"
  ) +
  scale_fill_manual(values = c("Jurídico e Contábil" = PALETA$ambar, "Impulsionamento Digital" = PALETA$azul)) +
  scale_y_continuous(labels = function(x) fmt_pct_br(x, 0), expand = expansion(mult = c(0, 0.16))) +
  labs(
    title = "Burocracia pesa 3,5× mais nas cidades pequenas; Digital cresce 8,4× nas metrópoles",
    subtitle = "Participação (%) no orçamento de campanha por porte populacional (Brasil 2024)",
    x = NULL,
    y = "Participação no Orçamento (%)",
    fill = NULL
  ) +
  tema_slide(base_size = 13) +
  theme(panel.grid.major.x = element_blank(), axis.text.x = element_text(angle = 12, hjust = 1))
salvar_fig(p_b9, "b9_digital_vs_burocracia_porte.png", width = 10.5, height = 6)

# --- B12: Taxa de Eleição de Prefeitos: Local vs. Forasteiro por Região ---
b12_df <- cand_df %>%
  filter(ds_cargo == "PREFEITO", !is.na(is_candidato_local), !is.na(regiao)) %>%
  group_by(regiao, is_candidato_local) %>%
  summarise(taxa_eleicao = 100 * mean(is_eleito), .groups = "drop") %>%
  mutate(origem = if_else(is_candidato_local, "Natural da UF (Local)", "Nascido Fora da UF (Forasteiro)"))

p_b12 <- ggplot(b12_df, aes(x = regiao, y = taxa_eleicao, fill = origem)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0(round(taxa_eleicao, 1), "%")), position = position_dodge(width = 0.9), vjust = -0.35, size = 3.1) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
  labs(
    title = "B12 · Taxa de Eleição de Prefeitos: Natural da UF vs. Nascido Fora (por Região)",
    x = "Macrorregião",
    y = "Taxa de Eleição (%)",
    fill = NULL
  ) +
  theme_minimal()
salvar_fig(p_b12, "b12_local_vs_forasteiro_regiao.png", width = 10, height = 6)

# --- B14: Custo Médio por Eleito (R$ mil) nos Top 12 Partidos por Arrecadação ---
b14_df <- part_df %>%
  group_by(sg_partido) %>%
  summarise(arrec = sum(total_arrecadado), eleitos = sum(qtd_eleitos), .groups = "drop") %>%
  slice_max(arrec, n = 12) %>%
  mutate(custo_mil_eleito = (arrec / eleitos) / 1e3)

p_b14 <- ggplot(b14_df, aes(x = custo_mil_eleito, y = fct_reorder(sg_partido, custo_mil_eleito))) +
  geom_col() +
  geom_text(aes(label = paste0("R$ ", round(custo_mil_eleito, 1), "k")), hjust = -0.1, size = 3.2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.16))) +
  labs(
    title = "B14 · Custo Médio Arrecadado por Eleito (Top 12 Partidos por Arrecadação)",
    x = "Arrecadação / Nº de Eleitos (R$ Mil)",
    y = NULL
  ) +
  theme_minimal()
salvar_fig(p_b14, "b14_custo_por_eleito_partidos.png", width = 10, height = 6)

# --- B16: Máquina Pública vs. Gasto Eleitoral em Cidades <20k ---
b16_df <- pca_df %>%
  filter(porte_municipio == "Pequeno Porte I (<20k)", !is.na(pct_adm_publica_vab_2021), !is.na(gasto_campanha_per_capita)) %>%
  mutate(
    faixa_adm = case_when(
      pct_adm_publica_vab_2021 < 20 ~ "Baixa (<20% VAB)",
      pct_adm_publica_vab_2021 < 35 ~ "Média (20%–35% VAB)",
      TRUE ~ "Alta (>=35% VAB)"
    ),
    faixa_adm = factor(faixa_adm, levels = c("Baixa (<20% VAB)", "Média (20%–35% VAB)", "Alta (>=35% VAB)"))
  ) %>%
  group_by(faixa_adm) %>%
  summarise(
    qtd_mun = n(),
    mediana_gasto_pc = median(gasto_campanha_per_capita),
    .groups = "drop"
  )

p_b16 <- ggplot(b16_df, aes(x = faixa_adm, y = mediana_gasto_pc, fill = faixa_adm)) +
  geom_col(width = 0.52) +
  geom_text(
    aes(label = paste0("R$ ", fmt_num_br(mediana_gasto_pc, 2), "/hab\n(n = ", fmt_int_br(qtd_mun), ")")),
    vjust = -0.3,
    size = 3.6,
    fontface = "bold",
    color = "#1e293b"
  ) +
  scale_fill_manual(values = c(
    "Baixa (<20% VAB)"     = PALETA$azul_suave,
    "Média (20%–35% VAB)"  = PALETA$azul_medio,
    "Alta (>=35% VAB)"     = PALETA$azul
  )) +
  scale_y_continuous(labels = function(x) paste0("R$ ", fmt_int_br(x)), expand = expansion(mult = c(0, 0.22))) +
  labs(
    title = "Em cidades <20 mil hab., alta dependência pública encarece a disputa eleitoral",
    subtitle = "Mediana do gasto total de campanha por habitante segundo peso da Administração Pública no VAB",
    x = "Peso da Administração Pública no VAB Municipal",
    y = "Mediana do Gasto por Habitante"
  ) +
  tema_slide(base_size = 13) +
  theme(legend.position = "none", panel.grid.major.x = element_blank())
salvar_fig(p_b16, "b16_maquina_publica_pequeno_porte.png", width = 9.5, height = 6)

# --- B18: Top 10 Categorias CNAE que Mais Faturaram ---
b18_df <- forn_df %>%
  filter(!is.na(ds_cnae_fornecedor)) %>%
  group_by(ds_cnae_fornecedor) %>%
  summarise(mi_reais = sum(valor_total_contratado, na.rm = TRUE) / 1e6, .groups = "drop") %>%
  slice_max(mi_reais, n = 10) %>%
  mutate(cnae_curto = str_trunc(ds_cnae_fornecedor, 48))

p_b18 <- ggplot(b18_df, aes(x = mi_reais, y = fct_reorder(cnae_curto, mi_reais))) +
  geom_col() +
  geom_text(aes(label = paste0("R$ ", round(mi_reais, 1), "M")), hjust = -0.1, size = 3) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.16))) +
  labs(
    title = "B18 · Top 10 Atividades Econômicas (CNAE) em Faturamento de Fornecedores",
    subtitle = "Entre fornecedores com 2+ candidatos atendidos no Brasil 2024",
    x = "Faturamento Total Contratado (R$ Milhões)",
    y = NULL
  ) +
  theme_minimal()
salvar_fig(p_b18, "b18_top10_cnae_fornecedores.png", width = 11, height = 6.5)
