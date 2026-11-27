# Dicionário de Dados: PRATA_DIMENSOES
> Gerado em: 2026-11-27 09:53:16.646507

## Base: `dim_candidato.parquet`
- **Linhas:** 463.731 | **Colunas:** 25

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `cd_municipio_tse` | string |
| `nr_partido` | int32 |
| `cd_cargo` | int32 |
| `ds_cargo` | string |
| `nr_candidato` | string |
| `nm_candidato` | string |
| `nm_urna_candidato` | string |
| `sg_uf_nascimento` | string |
| `is_candidato_local` | bool |
| `dt_nascimento` | date32[day] |
| `idade_2024` | int32 |
| `ds_genero` | string |
| `ds_cor_raca` | string |
| `ds_grau_instrucao` | string |
| `ds_estado_civil` | string |
| `ds_ocupacao` | string |
| `tp_agremiacao` | string |
| `nm_coligacao` | string |
| `ds_situacao_candidatura` | string |
| `ds_sit_tot_turno` | string |
| `nr_turno_final` | int32 |
| `disputou_segundo_turno` | bool |
| `is_eleito` | bool |
| `status_eleicao` | string |

---

## Base: `dim_municipio.parquet`
- **Linhas:** 5.571 | **Colunas:** 8

| Coluna | Tipo |
| ------ | ---- |
| `cd_municipio_ibge` | string |
| `cd_municipio_tse` | string |
| `sg_uf` | string |
| `regiao` | string |
| `nm_municipio` | string |
| `porte_municipio` | string |
| `is_capital` | bool |
| `tem_eleicao_municipal` | bool |

---

## Base: `dim_partido.parquet`
- **Linhas:** 29 | **Colunas:** 5

| Coluna | Tipo |
| ------ | ---- |
| `nr_partido` | int32 |
| `sg_partido` | string |
| `nm_partido` | string |
| `sg_federacao` | string |
| `nm_federacao` | string |

---

