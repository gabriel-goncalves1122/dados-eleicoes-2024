# Dicionário de Dados: OURO_DATAMARTS
> Gerado em: 2026-11-27 09:53:16.792848

## Base: `ouro_centralizacao_partidaria.parquet`
- **Linhas:** 425 | **Colunas:** 16

| Coluna | Tipo |
| ------ | ---- |
| `nr_partido` | int32 |
| `sg_partido` | string |
| `sg_federacao` | string |
| `regiao` | string |
| `ds_cargo` | string |
| `qtd_candidatos` | int32 |
| `qtd_eleitos` | int32 |
| `taxa_eleicao` | double |
| `total_arrecadado` | double |
| `vl_dir_nacional` | double |
| `vl_dir_estadual` | double |
| `vl_dir_municipal` | double |
| `vl_outras_fontes` | double |
| `pct_centralizacao_nacional` | double |
| `pct_dinheiro_fora_uf` | double |
| `custo_por_eleito` | double |

---

## Base: `ouro_concentracao_zonas.parquet`
- **Linhas:** 62.138 | **Colunas:** 14

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `sg_uf` | string |
| `regiao` | string |
| `nm_municipio` | string |
| `qtd_zonas_municipio` | int64 |
| `sg_partido` | string |
| `ds_cargo` | string |
| `is_eleito` | bool |
| `total_votos_1t` | int32 |
| `qtd_zonas_com_voto` | int32 |
| `hhi_voto_zonas` | double |
| `total_gasto` | double |
| `pct_gasto_digital` | double |
| `pct_gasto_militancia` | double |

---

## Base: `ouro_eficiencia_anomalias_candidatos.parquet`
- **Linhas:** 463.731 | **Colunas:** 20

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `sg_uf` | string |
| `regiao` | string |
| `porte_municipio` | string |
| `sg_partido` | string |
| `ds_cargo` | string |
| `ds_genero` | string |
| `ds_cor_raca` | string |
| `idade_2024` | int32 |
| `is_candidato_local` | bool |
| `disputou_segundo_turno` | bool |
| `is_eleito` | bool |
| `total_votos` | int32 |
| `votos_anulados_subjudice` | int32 |
| `total_arrecadado` | double |
| `total_fundo_publico` | double |
| `total_gasto` | double |
| `pct_receita_de_outros_candidatos` | double |
| `custo_por_voto` | double |
| `flag_anomalia_voto_recurso` | bool |

---

## Base: `ouro_estrutura_gastos_campanha.parquet`
- **Linhas:** 34.570 | **Colunas:** 10

| Coluna | Tipo |
| ------ | ---- |
| `sg_uf` | string |
| `regiao` | string |
| `porte_municipio` | string |
| `ds_cargo` | string |
| `is_eleito` | bool |
| `st_turno` | int32 |
| `semana_eleicao` | date32[day] |
| `macro_categoria_despesa` | string |
| `qtd_lancamentos` | int32 |
| `total_despesa` | double |

---

## Base: `ouro_fornecedores_rede.parquet`
- **Linhas:** 113.379 | **Colunas:** 12

| Coluna | Tipo |
| ------ | ---- |
| `nr_cpf_cnpj_fornecedor` | string |
| `nm_fornecedor` | string |
| `ds_cnae_fornecedor` | string |
| `macro_categoria_principal` | string |
| `qtd_lancamentos` | int32 |
| `qtd_candidatos` | int32 |
| `qtd_municipios` | int32 |
| `qtd_ufs` | int32 |
| `qtd_partidos` | int32 |
| `valor_total_contratado` | double |
| `ticket_medio` | double |
| `flag_rede_multi_municipio` | bool |

---

## Base: `ouro_patrimonio_composicao.parquet`
- **Linhas:** 463.731 | **Colunas:** 18

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `sg_uf` | string |
| `regiao` | string |
| `porte_municipio` | string |
| `sg_partido` | string |
| `ds_cargo` | string |
| `ds_genero` | string |
| `is_eleito` | bool |
| `qtd_bens` | int32 |
| `patrimonio_total` | double |
| `vl_imoveis_urbanos` | double |
| `vl_terra_rural` | double |
| `vl_empresas_acoes` | double |
| `vl_veiculos` | double |
| `vl_dinheiro_especie` | double |
| `vl_outros_aplicacoes` | double |
| `pct_dinheiro_especie` | double |
| `pct_terra_rural` | double |

---

## Base: `ouro_pca_municipios.parquet`
- **Linhas:** 5.569 | **Colunas:** 20

| Coluna | Tipo |
| ------ | ---- |
| `cd_municipio_tse` | string |
| `cd_municipio_ibge` | string |
| `sg_uf` | string |
| `regiao` | string |
| `nm_municipio` | string |
| `porte_municipio` | string |
| `is_capital` | bool |
| `prefeito_eleito_genero` | string |
| `prefeito_eleito_instrucao` | string |
| `pib_per_capita_reais` | double |
| `taxa_alfabetizacao_15mais` | double |
| `pct_populacao_urbana` | double |
| `pct_esgoto_adequado` | double |
| `pct_adm_publica_vab_2021` | double |
| `taxa_comparecimento_estimada` | double |
| `gasto_campanha_per_capita` | double |
| `custo_medio_voto_municipio` | double |
| `pct_fundo_publico_municipio` | double |
| `pct_cand_mulheres` | double |
| `pct_eleitos_mulheres` | double |

---

## Base: `ouro_representatividade_municipal.parquet`
- **Linhas:** 5.569 | **Colunas:** 18

| Coluna | Tipo |
| ------ | ---- |
| `cd_municipio_tse` | string |
| `cd_municipio_ibge` | string |
| `sg_uf` | string |
| `regiao` | string |
| `nm_municipio` | string |
| `porte_municipio` | string |
| `is_capital` | bool |
| `pct_mulheres_censo` | double |
| `pct_negros_indigenas_censo` | double |
| `pct_cand_mulheres` | double |
| `pct_fundo_publico_mulheres` | double |
| `pct_eleitos_mulheres` | double |
| `pct_cand_negros_indigenas` | double |
| `pct_fundo_publico_negros_indigenas` | double |
| `pct_eleitos_negros_indigenas` | double |
| `gap_eleitos_mulheres` | double |
| `gap_eleitos_negros_indigenas` | double |
| `gap_financiamento_mulheres` | double |

---

