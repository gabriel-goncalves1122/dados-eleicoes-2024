# Dicionário de Dados: SILVER_TSE_PARQUET
> Gerado em: 2026-11-16 11:09:17.119338

## Base: `bens_candidatos_clean.parquet`
- **Linhas:** 100.971 | **Colunas:** 3

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `total_patrimonio_declarado` | double |
| `qtd_bens_declarados` | int32 |

---

## Base: `candidatos_clean.parquet`
- **Linhas:** 151.868 | **Colunas:** 26

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

---

## Base: `despesas_clean.parquet`
- **Linhas:** 1.276.510 | **Colunas:** 10

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `sg_uf` | string |
| `cd_municipio_tse` | string |
| `dt_despesa` | date32[day] |
| `ds_origem_despesa` | string |
| `ds_despesa` | string |
| `ds_tipo_documento` | string |
| `vr_despesa_contratada` | double |
| `nr_cpf_cnpj_fornecedor` | string |
| `nm_fornecedor` | string |

---

## Base: `receitas_clean.parquet`
- **Linhas:** 713.921 | **Colunas:** 12

| Coluna | Tipo |
| ------ | ---- |
| `sq_candidato` | string |
| `sg_uf` | string |
| `cd_municipio_tse` | string |
| `dt_receita` | date32[day] |
| `ds_fonte_receita` | string |
| `ds_origem_receita` | string |
| `ds_natureza_receita` | string |
| `ds_especie_receita` | string |
| `vr_receita` | double |
| `nr_cpf_cnpj_doador` | string |
| `nm_doador` | string |
| `is_fundo_publico` | bool |

---

## Base: `votacao_munzona_clean.parquet`
- **Linhas:** 254.878 | **Colunas:** 11

| Coluna | Tipo |
| ------ | ---- |
| `nr_turno` | int8 |
| `dt_eleicao` | date32[day] |
| `sg_uf` | string |
| `cd_municipio_tse` | string |
| `nm_municipio` | string |
| `nr_zona` | int16 |
| `cd_cargo` | int16 |
| `ds_cargo` | string |
| `sq_candidato` | string |
| `nr_candidato` | string |
| `qt_votos_nominais` | int32 |

---

