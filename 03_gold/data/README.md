# Dicionário de Dados: GOLD_DATAMARTS_PARQUET
> Gerado em: 2026-11-16 11:09:17.212962

## Base: `datamart_candidatos_2024.parquet`
- **Linhas:** 151.868 | **Colunas:** 36

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `nr_candidato` | string |
| `nm_candidato` | string |
| `nm_urna_candidato` | string |
| `sg_uf` | string |
| `cd_municipio_tse` | string |
| `nm_municipio` | string |
| `cd_cargo` | int16 |
| `ds_cargo` | string |
| `nr_partido` | int16 |
| `sg_partido` | string |
| `nm_partido` | string |
| `tp_agremiacao` | string |
| `sg_federacao` | string |
| `ds_genero` | string |
| `ds_cor_raca` | string |
| `ds_grau_instrucao` | string |
| `ds_estado_civil` | string |
| `ds_ocupacao` | string |
| `dt_nascimento` | date32[day] |
| `nr_turno` | int8 |
| `dt_eleicao` | date32[day] |
| `ds_sit_tot_turno` | string |
| `idade_2024` | int16 |
| `is_eleito` | bool |
| `status_eleicao` | string |
| `total_arrecadado` | double |
| `total_fundo_publico` | double |
| `total_gasto` | double |
| `total_votos` | int32 |
| `qtd_zonas_com_voto` | int32 |
| `total_patrimonio_declarado` | double |
| `qtd_bens_declarados` | int32 |
| `pct_fundo_publico` | double |
| `custo_por_voto` | double |
| `roi_votos_por_real` | double |

---

## Base: `datamart_despesas_2024.parquet`
- **Linhas:** 13.213 | **Colunas:** 7

| Coluna | Tipo |
| ------ | ---- |
| `sg_uf` | string |
| `ds_cargo` | string |
| `is_eleito` | bool |
| `ds_origem_despesa` | string |
| `dt_despesa` | date32[day] |
| `qtd_lancamentos` | int32 |
| `total_despesa` | double |

---

## Base: `datamart_eleitoral_socioeconomico_2024.parquet`
- **Linhas:** 1.498 | **Colunas:** 62

| Coluna | Tipo |
| ------ | ---- |
| `sg_uf` | string |
| `cd_municipio_tse` | string |
| `nm_municipio` | string |
| `total_candidatos` | int32 |
| `total_eleitos` | int32 |
| `pct_cand_mulheres` | double |
| `pct_cand_branca` | double |
| `pct_cand_preta` | double |
| `pct_cand_parda` | double |
| `pct_cand_indigena` | double |
| `pct_cand_negros_indigenas` | double |
| `pct_eleitos_mulheres` | double |
| `pct_eleitos_branca` | double |
| `pct_eleitos_preta` | double |
| `pct_eleitos_parda` | double |
| `pct_eleitos_indigena` | double |
| `pct_eleitos_negros_indigenas` | double |
| `total_votos_nominais` | int64 |
| `total_gasto_campanhas` | double |
| `total_arrecadado_campanhas` | double |
| `total_fundo_publico_municipio` | double |
| `prefeito_eleito_nome` | string |
| `prefeito_eleito_partido` | string |
| `prefeito_eleito_genero` | string |
| `prefeito_eleito_raca` | string |
| `prefeito_eleito_instrucao` | string |
| `prefeito_eleito_votos` | int32 |
| `prefeito_eleito_gasto` | double |
| `custo_medio_voto_municipio` | double |
| `pct_fundo_publico_municipio` | double |
| `cd_municipio_ibge` | string |
| `cd_municipio_ibge_6` | string |
| `nm_municipio_tse` | string |
| `is_capital` | bool |
| `nm_municipio_ibge` | string |
| `populacao_2022` | int64 |
| `pib_reais_2023` | double |
| `pib_per_capita_reais` | double |
| `vab_adm_publica_reais_2021` | double |
| `pct_adm_publica_vab_2021` | double |
| `pct_impostos_pib_2021` | double |
| `taxa_alfabetizacao_15mais` | double |
| `pct_populacao_urbana` | double |
| `pct_agua_rede_geral` | double |
| `pct_esgoto_adequado` | double |
| `pct_sem_banheiro` | double |
| `pct_mulheres_censo` | double |
| `pct_branca_censo` | double |
| `pct_preta_censo` | double |
| `pct_parda_censo` | double |
| `pct_indigena_censo` | double |
| `pct_negros_indigenas_censo` | double |
| `gasto_campanha_per_capita` | double |
| `taxa_comparecimento_estimada` | double |
| `gap_cand_mulheres` | double |
| `gap_eleitos_mulheres` | double |
| `gap_cand_negros_indigenas` | double |
| `gap_eleitos_negros_indigenas` | double |
| `gap_eleitos_branca` | double |
| `gap_eleitos_preta` | double |
| `gap_eleitos_parda` | double |
| `porte_municipio` | string |

---

## Base: `datamart_municipal_2024.parquet`
- **Linhas:** 1.498 | **Colunas:** 30

| Coluna | Tipo |
| ------ | ---- |
| `sg_uf` | string |
| `cd_municipio_tse` | string |
| `nm_municipio` | string |
| `total_candidatos` | int32 |
| `total_eleitos` | int32 |
| `pct_cand_mulheres` | double |
| `pct_cand_branca` | double |
| `pct_cand_preta` | double |
| `pct_cand_parda` | double |
| `pct_cand_indigena` | double |
| `pct_cand_negros_indigenas` | double |
| `pct_eleitos_mulheres` | double |
| `pct_eleitos_branca` | double |
| `pct_eleitos_preta` | double |
| `pct_eleitos_parda` | double |
| `pct_eleitos_indigena` | double |
| `pct_eleitos_negros_indigenas` | double |
| `total_votos_nominais` | int64 |
| `total_gasto_campanhas` | double |
| `total_arrecadado_campanhas` | double |
| `total_fundo_publico_municipio` | double |
| `prefeito_eleito_nome` | string |
| `prefeito_eleito_partido` | string |
| `prefeito_eleito_genero` | string |
| `prefeito_eleito_raca` | string |
| `prefeito_eleito_instrucao` | string |
| `prefeito_eleito_votos` | int32 |
| `prefeito_eleito_gasto` | double |
| `custo_medio_voto_municipio` | double |
| `pct_fundo_publico_municipio` | double |

---

