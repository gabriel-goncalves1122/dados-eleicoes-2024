# ==============================================================================
# ANALYTICS 07: FUNIL DE REPRESENTATIVIDADE FEMININA (CENSO vs. URNAS 2024)
# ==============================================================================
# Visualização direta: compara a presença feminina em 4 estágios (População Censo,
# Candidatas, Vereadoras Eleitas e Prefeitas Eleitas) em MG e SP.

if (file.exists("src/config.R")) {
  source("src/config.R")
} else {
  source("../../src/config.R")
}
source("analises/eleicoes/_helpers_vis.R")

cand <- read_parquet("dados/ouro/datamart_candidatos_2024.parquet")
mun  <- read_parquet("dados/ouro/datamart_eleitoral_socioeconomico_2024.parquet")

censo_uf <- mun %>%
  group_by(sg_uf) %>%
  summarise(pct = weighted.mean(pct_mulheres_censo, populacao_2022, na.rm = TRUE), .groups = "drop") %>%
  mutate(estagio = "1. População (Censo 2022)")

cand_uf <- cand %>%
  filter(!is.na(ds_genero)) %>%
  group_by(sg_uf) %>%
  summarise(pct = mean(ds_genero == "FEMININO") * 100, .groups = "drop") %>%
  mutate(estagio = "2. Candidatas (Cota 30%)")

ver_uf <- cand %>%
  filter(cd_cargo == 13L, is_eleito, !is.na(ds_genero)) %>%
  group_by(sg_uf) %>%
  summarise(pct = mean(ds_genero == "FEMININO") * 100, .groups = "drop") %>%
  mutate(estagio = "3. Vereadoras Eleitas")

pref_uf <- cand %>%
  filter(cd_cargo == 11L, is_eleito, !is.na(ds_genero)) %>%
  group_by(sg_uf) %>%
  summarise(pct = mean(ds_genero == "FEMININO") * 100, .groups = "drop") %>%
  mutate(estagio = "4. Prefeitas Eleitas")

funil_genero <- bind_rows(censo_uf, cand_uf, ver_uf, pref_uf) %>%
  mutate(estagio = factor(estagio, levels = c(
    "1. População (Censo 2022)", "2. Candidatas (Cota 30%)",
    "3. Vereadoras Eleitas", "4. Prefeitas Eleitas"
  )))

g7 <- ggplot(funil_genero, aes(
  x = estagio, y = pct, fill = sg_uf,
  text = paste("Estado:", sg_uf, "<br>Estágio:", estagio, "<br>Mulheres:", round(pct, 1), "%")
)) +
  geom_col(position = position_dodge(width = 0.72), width = 0.65) +
  geom_hline(yintercept = 50, linetype = "dashed", color = "#0f172a") +
  geom_hline(yintercept = 30, linetype = "dotted", color = "#e11d48") +
  scale_y_continuous(limits = c(0, 60), labels = function(x) paste0(x, "%")) +
  scale_fill_manual(values = c("MG" = "#2563eb", "SP" = "#f59e0b")) +
  labs(
    title = "Funil da Representatividade Feminina: Da População às Eleitas (2024)",
    subtitle = "Linha tracejada = paridade (50%) | Pontilhada = cota mínima de candidaturas (30%)",
    x = NULL, y = "Proporção de Mulheres (%)", fill = "Estado (UF)"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

salvar_e_exibir_plotly(g7, "07_representatividade_genero_censo_urnas.html")
