# ==============================================================================
# PAINEL 01: KPIs (K1, K3, K4) E GRÁFICOS DE PIZZA / ROSCA (P1, P2, P4)
# ==============================================================================

if (file.exists("analises/painel/_helpers_painel.R")) {
  source("analises/painel/_helpers_painel.R")
} else {
  source("_helpers_painel.R")
}

message("=== [Painel 01] Gerando KPIs (K1, K3, K4) e Pizzas (P1, P2, P4) ===")

pca_df  <- ler_ouro("ouro_pca_municipios.parquet")
cand_df <- ler_ouro("ouro_eficiencia_anomalias_candidatos.parquet")
part_df <- ler_ouro("ouro_centralizacao_partidaria.parquet")
gast_df <- ler_ouro("ouro_estrutura_gastos_campanha.parquet")

# --- KPIs (K1, K3, K4) ---
n_muns   <- nrow(pca_df)
n_cands  <- nrow(cand_df)
vl_nac   <- sum(part_df$vl_dir_nacional, na.rm = TRUE)
vl_jur   <- gast_df %>% filter(macro_categoria_despesa == "Jurídico e Contábil") %>% summarise(s = sum(total_despesa)) %>% pull(s)
vl_dig   <- gast_df %>% filter(macro_categoria_despesa == "Impulsionamento Digital") %>% summarise(s = sum(total_despesa)) %>% pull(s)

kpis <- tibble(
  id = c("K1", "K3", "K4"),
  indicador = c(
    "Escala da Eleição Municipal 2024",
    "Recursos via Diretórios Nacionais",
    "Burocracia (Jurídico+Contábil) vs. Digital"
  ),
  valor_principal = c(
    paste0(format(n_muns, big.mark = "."), " municípios | ", format(n_cands, big.mark = "."), " candidatos"),
    paste0("R$ ", round(vl_nac / 1e9, 2), " bilhões"),
    paste0("R$ ", round(vl_jur / 1e6, 1), "M vs. R$ ", round(vl_dig / 1e6, 1), "M (", round(vl_jur / vl_dig, 2), "x)")
  )
)
salvar_tab(kpis, "kpis_k1_k3_k4.csv")

p_kpis <- ggplot(kpis, aes(x = 1, y = factor(id, levels = rev(id)))) +
  geom_tile(fill = "gray95", color = "gray70", width = 0.9, height = 0.75) +
  geom_text(aes(label = paste0("[", id, "] ", indicador, "\n", valor_principal)), size = 4.2, fontface = "bold") +
  labs(title = "KPIs Executivos — Eleições Municipais Brasil 2024") +
  theme_void()
salvar_fig(p_kpis, "k1_k3_k4_painel_kpis.png", width = 9, height = 4.5)

# --- P1: Fundo Público vs. Outras Fontes ---
tot_arrec <- sum(cand_df$total_arrecadado, na.rm = TRUE)
tot_fp    <- sum(cand_df$total_fundo_publico, na.rm = TRUE)
p1_df <- tibble(
  categoria = c("Fundo Público (FEFC + Partidário)", "Outras Fontes / Privado"),
  valor = c(tot_fp, pmax(tot_arrec - tot_fp, 0))
)
salvar_fig(
  fazer_pizza(
    p1_df,
    "73,4% das campanhas foram financiadas com dinheiro público",
    paste0("Arrecadação total nas eleições municipais 2024: ", fmt_reais_curto(tot_arrec)),
    cores = c("Fundo Público (FEFC + Partidário)" = PALETA$azul, "Outras Fontes / Privado" = PALETA$slate)
  ),
  "p1_pizza_origem_recursos.png", width = 8.5, height = 5.8
)

# --- P2: Quem manda no dinheiro dos partidos (Esfera Doadora) ---
p2_df <- tibble(
  categoria = c("Diretório Nacional", "Diretório Estadual", "Diretório Municipal", "Outras Fontes / Não-Partido"),
  valor = c(
    sum(part_df$vl_dir_nacional, na.rm = TRUE),
    sum(part_df$vl_dir_estadual, na.rm = TRUE),
    sum(part_df$vl_dir_municipal, na.rm = TRUE),
    sum(part_df$vl_outras_fontes, na.rm = TRUE)
  )
)
salvar_fig(
  fazer_pizza(p2_df, "P2 · Distribuição por Esfera Partidária Doadora (Brasil 2024)"),
  "p2_pizza_esfera_partidaria.png", width = 8, height = 5.5
)

# --- P4: Gênero nas Prefeituras Eleitas ---
p4_df <- pca_df %>%
  filter(!is.na(prefeito_eleito_genero)) %>%
  count(categoria = prefeito_eleito_genero, name = "valor")
salvar_fig(
  fazer_pizza(p4_df, "P4 · Divisão de Gênero entre Prefeitos Eleitos (Brasil 2024)",
              paste0("Total analisado: ", sum(p4_df$valor), " municípios")),
  "p4_pizza_genero_prefeitos.png", width = 8, height = 5.5
)
