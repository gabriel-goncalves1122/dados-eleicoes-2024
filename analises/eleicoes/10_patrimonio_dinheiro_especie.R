# ==============================================================================
# ANÁLISE 10: A GEOGRAFIA DO CAPITAL POLÍTICO E O "EFEITO DINHEIRO VIVO"
# ==============================================================================
# Tese: Prefeitos eleitos do Centro-Oeste lideram riqueza mediana (terra rural + empresas),
# enquanto dinheiro em espécie soma R$ 1,35 bi com maior participação relativa no NE e SE.

if (file.exists("analises/eleicoes/_helpers_analise.R")) {
  source("analises/eleicoes/_helpers_analise.R")
} else {
  source("_helpers_analise.R")
}

message("=== [10] Composição Patrimonial e Dinheiro em Espécie ===")

df <- ler_ouro("ouro_patrimonio_composicao.parquet") %>%
  filter(!is.na(regiao))

comp_pref <- df %>%
  filter(ds_cargo == "PREFEITO", is_eleito) %>%
  group_by(regiao) %>%
  summarise(
    qtd_prefeitos = n(),
    patrimonio_mediano = median(patrimonio_total),
    `Imóveis Urbanos` = 100 * sum(vl_imoveis_urbanos) / sum(patrimonio_total),
    `Terra Rural` = 100 * sum(vl_terra_rural) / sum(patrimonio_total),
    `Empresas e Ações` = 100 * sum(vl_empresas_acoes) / sum(patrimonio_total),
    `Veículos` = 100 * sum(vl_veiculos) / sum(patrimonio_total),
    `Dinheiro em Espécie` = 100 * sum(vl_dinheiro_especie) / sum(patrimonio_total),
    `Outros e Aplicações` = 100 * sum(vl_outros_aplicacoes) / sum(patrimonio_total),
    .groups = "drop"
  )
salvar_tabela(comp_pref, "10_composicao_patrimonial_prefeitos.csv")

ordem_classes <- c(
  "Imóveis Urbanos", "Outros e Aplicações", "Empresas e Ações",
  "Terra Rural", "Veículos", "Dinheiro em Espécie"
)

cores_patrimonio <- c(
  "Imóveis Urbanos"     = PALETA$azul,
  "Outros e Aplicações" = PALETA$azul_suave,
  "Empresas e Ações"    = PALETA$esmeralda,
  "Terra Rural"         = PALETA$ambar,
  "Veículos"            = PALETA$slate,
  "Dinheiro em Espécie" = PALETA$carmim
)

comp_long <- comp_pref %>%
  select(-qtd_prefeitos, -patrimonio_mediano) %>%
  pivot_longer(-regiao, names_to = "classe_ativo", values_to = "pct") %>%
  left_join(comp_pref %>% select(regiao, patrimonio_mediano), by = "regiao") %>%
  mutate(
    regiao_rot = paste0(regiao, "\n(med. ", fmt_reais_curto(patrimonio_mediano), ")"),
    classe_ativo = factor(classe_ativo, levels = rev(ordem_classes))
  )

p_comp <- ggplot(comp_long, aes(x = pct, y = fct_reorder(regiao_rot, patrimonio_mediano), fill = classe_ativo)) +
  geom_col(position = "stack", width = 0.72) +
  geom_text(
    aes(label = ifelse(pct >= 7.5, fmt_pct_br(pct, 0), "")),
    position = position_stack(vjust = 0.5),
    size = 3.3, fontface = "bold", color = "white"
  ) +
  scale_fill_manual(values = cores_patrimonio) +
  guides(fill = guide_legend(reverse = TRUE, nrow = 1)) +
  scale_x_continuous(labels = function(x) fmt_pct_br(x, 0), expand = expansion(mult = c(0, 0.02))) +
  labs(
    title = "Centro-Oeste concentra maior riqueza (R$ 926 mil) puxada por terra rural e empresas",
    subtitle = "Composição patrimonial dos prefeitos eleitos por região (ordenadas pela mediana patrimonial)",
    x = "Participação no Patrimônio Total (%)",
    y = NULL,
    fill = NULL
  ) +
  tema_slide(base_size = 13) +
  theme(panel.grid.major.y = element_blank())
salvar_grafico(p_comp, "10a_composicao_patrimonio_prefeitos.png", width = 11.5, height = 6.3)

# Gráfico 10b: Distribuição de Dinheiro em Espécie (>0) por Região e Status Eleitoral
especie_df <- df %>%
  filter(vl_dinheiro_especie > 0) %>%
  mutate(status = if_else(is_eleito, "Eleitos", "Não Eleitos"))

resumo_especie <- especie_df %>%
  group_by(regiao, status) %>%
  summarise(
    qtd_declarantes = n(),
    soma_mi = sum(vl_dinheiro_especie) / 1e6,
    mediana_especie = median(vl_dinheiro_especie),
    p90_especie = quantile(vl_dinheiro_especie, 0.90),
    .groups = "drop"
  )
salvar_tabela(resumo_especie, "10_dinheiro_especie_regiao_status.csv")

p_esp <- ggplot(especie_df, aes(x = vl_dinheiro_especie, fill = status)) +
  geom_density(alpha = 0.45) +
  facet_wrap(~regiao, scales = "free_y") +
  scale_x_log10(labels = label_dollar(prefix = "R$ ", big.mark = ".")) +
  labs(
    title = "Distribuição do Dinheiro em Espécie Declarado (Candidatos com Valor > 0)",
    subtitle = "Escala log10 comparando declarantes Eleitos vs. Não Eleitos nas 5 regiões",
    x = "Valor Declarado em Espécie (escala log10)",
    y = "Densidade",
    fill = "Resultado"
  ) +
  theme_minimal()
salvar_grafico(p_esp, "10b_dinheiro_especie_densidade_log.png", width = 12, height = 7)
