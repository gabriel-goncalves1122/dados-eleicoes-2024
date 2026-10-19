# Dicionário de Dados: Camada PROCESSED_PARQUET
> Gerado automaticamente em: 2026-08-24 19:56:15.476931

Este diretório contém os seguintes datasets analisados:

## Base: `candidatos_clean.parquet`
- **Total de Linhas:** 29.292
- **Total de Colunas:** 15

### Esquema de Colunas
| Nome da Coluna | Tipo de Dado |
| -------------- | ------------ |
| `SQ_CANDIDATO` | string |
| `NM_CANDIDATO` | string |
| `NM_URNA_CANDIDATO` | string |
| `NR_CPF_CANDIDATO` | string |
| `SG_UF` | string |
| `SG_PARTIDO` | string |
| `DS_CARGO` | string |
| `DS_GENERO` | string |
| `DS_COR_RACA` | string |
| `DS_OCUPACAO` | string |
| `DS_GRAU_INSTRUCAO` | string |
| `DT_NASCIMENTO` | string |
| `DS_SIT_TOT_TURNO` | string |
| `Idade_2022` | double |
| `Status_Eleicao` | string |

---

## Base: `despesas_clean`
- **Total de Linhas:** 2.209.822
- **Total de Colunas:** 7

### Esquema de Colunas
| Nome da Coluna | Tipo de Dado |
| -------------- | ------------ |
| `SQ_CANDIDATO` | string |
| `DT_DESPESA` | string |
| `DS_ORIGEM_DESPESA` | string |
| `DS_DESPESA` | string |
| `VR_DESPESA_CONTRATADA` | double |
| `NR_CPF_CNPJ_FORNECEDOR` | string |
| `NM_FORNECEDOR` | string |

---

## Base: `receitas_clean`
- **Total de Linhas:** 674.944
- **Total de Colunas:** 9

### Esquema de Colunas
| Nome da Coluna | Tipo de Dado |
| -------------- | ------------ |
| `SQ_CANDIDATO` | string |
| `DT_RECEITA` | string |
| `DS_FONTE_RECEITA` | string |
| `DS_NATUREZA_RECEITA` | string |
| `DS_ESPECIE_RECEITA` | string |
| `VR_RECEITA` | double |
| `NR_CPF_CNPJ_DOADOR` | string |
| `NM_DOADOR` | string |
| `Flag_Dinheiro_Publico` | bool |

---

## Base: `votacao_munzona_clean`
- **Total de Linhas:** 9.377.845
- **Total de Colunas:** 6

### Esquema de Colunas
| Nome da Coluna | Tipo de Dado |
| -------------- | ------------ |
| `SQ_CANDIDATO` | string |
| `SG_UF` | string |
| `CD_MUNICIPIO` | int64 |
| `NM_MUNICIPIO` | string |
| `NR_ZONA` | int64 |
| `QT_VOTOS_NOMINAIS` | int32 |

---

## Base: `votacao_munzona_clean.parquet`
- **Total de Linhas:** 9.377.845
- **Total de Colunas:** 6

### Esquema de Colunas
| Nome da Coluna | Tipo de Dado |
| -------------- | ------------ |
| `SQ_CANDIDATO` | string |
| `SG_UF` | string |
| `CD_MUNICIPIO` | int32 |
| `NM_MUNICIPIO` | binary |
| `NR_ZONA` | int32 |
| `QT_VOTOS_NOMINAIS` | int32 |

---

