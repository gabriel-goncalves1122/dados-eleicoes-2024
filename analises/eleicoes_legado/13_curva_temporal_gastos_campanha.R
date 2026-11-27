# ==============================================================================
# ANALYTICS 13: CURVA TEMPORAL DOS GASTOS DE CAMPANHA (AGO–OUT 2024)
# ==============================================================================
# Responde: Qual o ritmo diário de execução financeira até o 1º e 2º turnos?

if (file.exists("src/config.R")) {
  source("src/config.R")
} else {
  source("../../src/config.R")
}
source("analises/eleicoes/_helpers_vis.R")

df_tempo <- read_parquet("dados/ouro/datamart_despesas_2024.parquet") %>%
  filter(dt_despesa >= as.Date("2024-08-15"), dt_despesa <= as.Date("2024-10-31")) %>%
  group_by(dt_despesa, sg_uf) %>%
  summarise(gasto_diario_mi = sum(total_despesa, na.rm = TRUE) / 1e6, .groups = "drop")

g13 <- ggplot(df_tempo, aes(
  x = dt_despesa, y = gasto_diario_mi, color = sg_uf, group = sg_uf,
  text = paste(
    "Data:", dt_despesa,
    "<br>Estado:", sg_uf,
    "<br>Gasto no Dia: R$", round(gasto_diario_mi, 2), "Mi"
  )
)) +
  geom_line(linewidth = 0.9, alpha = 0.85) +
  geom_vline(xintercept = as.numeric(as.Date("2024-10-06")), linetype = "dashed", color = "#ef4444") +
  geom_vline(xintercept = as.numeric(as.Date("2024-10-27")), linetype = "dotted", color = "#334155") +
  scale_color_manual(values = c("MG" = "#2563eb", "SP" = "#f59e0b")) +
  labs(
    title = "Curva Temporal dos Gastos Eleitorais Diários (Ago–Out 2024)",
    subtitle = "Linha tracejada vermelha = 1º Turno (06/10/2024) | Pontilhada = 2º Turno (27/10/2024)",
    x = "Data da Despesa", y = "Gasto Contratado Diário (Milhões R$)", color = "Estado (UF)"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g13, "13_curva_temporal_gastos_campanha.html")
