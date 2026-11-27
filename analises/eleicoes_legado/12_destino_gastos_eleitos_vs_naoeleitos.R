# ==============================================================================
# ANALYTICS 12: DESTINO DOS GASTOS — ELEITOS VS. NÃO ELEITOS (2024)
# ==============================================================================
# Responde: Em quais categorias se concentra o dinheiro das campanhas e como a
# alocação proporcional difere entre candidatos eleitos e não eleitos?

if (file.exists("src/config.R")) {
  source("src/config.R")
} else {
  source("../../src/config.R")
}
source("analises/eleicoes/_helpers_vis.R")

df_desp <- read_parquet("dados/ouro/datamart_despesas_2024.parquet")

top_cats <- df_desp %>%
  group_by(ds_origem_despesa) %>%
  summarise(tot = sum(total_despesa), .groups = "drop") %>%
  slice_max(tot, n = 10) %>%
  pull(ds_origem_despesa)

comp_gastos <- df_desp %>%
  filter(ds_origem_despesa %in% top_cats) %>%
  mutate(status = ifelse(is_eleito, "Eleitos", "Não Eleitos")) %>%
  group_by(status, ds_origem_despesa) %>%
  summarise(valor_mi = sum(total_despesa) / 1e6, .groups = "drop") %>%
  group_by(status) %>%
  mutate(pct = (valor_mi / sum(valor_mi)) * 100) %>%
  ungroup() %>%
  mutate(ds_origem_despesa = fct_reorder(ds_origem_despesa, valor_mi))

g12 <- ggplot(comp_gastos, aes(
  x = pct, y = ds_origem_despesa, fill = status,
  text = paste(
    "Categoria:", ds_origem_despesa,
    "<br>Grupo:", status,
    "<br>Participação:", round(pct, 1), "%",
    "<br>Total Gasto: R$", round(valor_mi, 2), "Mi"
  )
)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("Eleitos" = "#10b981", "Não Eleitos" = "#64748b")) +
  labs(
    title = "Composição dos Gastos de Campanha: Eleitos vs. Não Eleitos (Top 10 Categorias)",
    subtitle = "Participação percentual sobre os R$ 1,84 bilhão contratados em MG e SP",
    x = "Participação no Orçamento (%)", y = NULL, fill = "Status"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g12, "12_destino_gastos_eleitos_vs_naoeleitos.html")
