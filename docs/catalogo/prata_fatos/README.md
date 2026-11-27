# Dicionário de Dados: PRATA_FATOS
> Gerado em: 2026-11-27 09:53:16.70686

## Base: `fato_bens.parquet`
- **Linhas:** 911.354 | **Colunas:** 5

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `nr_ordem_bem` | int32 |
| `ds_tipo_bem` | string |
| `ds_bem_candidato` | string |
| `vr_bem` | double |

---

## Base: `fato_despesas.parquet`
- **Linhas:** 4.453.470 | **Colunas:** 15

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `cd_municipio_tse` | string |
| `dt_despesa` | date32[day] |
| `st_turno` | int32 |
| `vr_despesa_contratada` | double |
| `ds_origem_despesa` | string |
| `ds_despesa` | string |
| `ds_tipo_documento` | string |
| `nr_cpf_cnpj_fornecedor` | string |
| `nm_fornecedor` | string |
| `cd_cnae_fornecedor` | string |
| `ds_cnae_fornecedor` | string |
| `sg_uf_fornecedor` | string |
| `cd_municipio_fornecedor` | string |
| `ds_esfera_part_fornecedor` | string |

---

## Base: `fato_indicadores_municipio.parquet`
- **Linhas:** 5.570 | **Colunas:** 19

| Coluna | Tipo |
| ------ | ---- |
| `cd_municipio_ibge` | string |
| `populacao_2022` | int32 |
| `pib_reais_2023` | double |
| `vab_adm_publica_reais_2021` | double |
| `vab_total_reais_2021` | double |
| `pct_adm_publica_vab_2021` | double |
| `pct_impostos_pib_2021` | double |
| `taxa_alfabetizacao_15mais` | double |
| `pct_populacao_urbana` | double |
| `pct_agua_rede_geral` | double |
| `pct_esgoto_adequado` | double |
| `pct_sem_banheiro` | double |
| `pct_branca_censo` | double |
| `pct_preta_censo` | double |
| `pct_parda_censo` | double |
| `pct_indigena_censo` | double |
| `pct_negros_indigenas_censo` | double |
| `pct_mulheres_censo` | double |
| `pib_per_capita_reais` | double |

---

## Base: `fato_receitas.parquet`
- **Linhas:** 2.041.160 | **Colunas:** 18

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `cd_municipio_tse` | string |
| `dt_receita` | date32[day] |
| `st_turno` | int32 |
| `vr_receita` | double |
| `ds_fonte_receita` | string |
| `ds_origem_receita` | string |
| `ds_natureza_receita` | string |
| `ds_especie_receita` | string |
| `nr_cpf_cnpj_doador` | string |
| `nm_doador` | string |
| `cd_cnae_doador` | string |
| `ds_cnae_doador` | string |
| `sg_uf_doador` | string |
| `cd_municipio_doador` | string |
| `ds_esfera_partidaria_doador` | string |
| `sq_candidato_doador` | string |
| `is_fundo_publico` | bool |

---

## Base: `fato_votacao.parquet`
- **Linhas:** 717.171 | **Colunas:** 9

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `cd_municipio_tse` | string |
| `nr_turno` | int32 |
| `dt_eleicao` | date32[day] |
| `nr_zona` | int32 |
| `qt_votos_nominais` | int32 |
| `qt_votos_nominais_validos` | int32 |
| `ds_sit_tot_turno` | string |
| `st_voto_em_transito` | bool |

---

