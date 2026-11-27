# EDA & Data Profiling — Camada Bronze (100% Parquet)
> Gerado em: `2026-11-16 10:17:11` | Datasets: **15** | Registros Totais: **2,865,562** | Espaço em Disco: **116.82 MB**

## 1. Visão Geral dos Datasets

| Domínio | Dataset | Arquivo | Linhas | Colunas | Tamanho (MB) | Duplicatas |
| :--- | :--- | :--- | ---: | ---: | ---: | ---: |
| `integracao` | **depara_tse_ibge** | `01_bronze/data/depara_tse_ibge.parquet` | 1,498 | 6 | 0.02 | 0 |
| `ibge` | **censo2022_abastecimento_agua** | `01_bronze/data/ibge/censo2022_abastecimento_agua.parquet` | 5,570 | 5 | 0.07 | 0 |
| `ibge` | **censo2022_cor_raca_sexo** | `01_bronze/data/ibge/censo2022_cor_raca_sexo.parquet` | 66,840 | 6 | 0.09 | 0 |
| `ibge` | **censo2022_esgotamento_sanitario** | `01_bronze/data/ibge/censo2022_esgotamento_sanitario.parquet` | 11,140 | 5 | 0.08 | 0 |
| `ibge` | **censo2022_taxa_alfabetizacao** | `01_bronze/data/ibge/censo2022_taxa_alfabetizacao.parquet` | 5,570 | 3 | 0.07 | 0 |
| `ibge` | **censo2022_urbana_rural** | `01_bronze/data/ibge/censo2022_urbana_rural.parquet` | 22,280 | 7 | 0.12 | 0 |
| `ibge` | **pib_composicao_setorial** | `01_bronze/data/ibge/pib_composicao_setorial.parquet` | 22,280 | 6 | 0.09 | 0 |
| `ibge` | **pib_municipal** | `01_bronze/data/ibge/pib_municipal.parquet` | 5,570 | 4 | 0.07 | 0 |
| `ibge` | **pib_peso_administracao_publica** | `01_bronze/data/ibge/pib_peso_administracao_publica.parquet` | 11,140 | 6 | 0.06 | 0 |
| `ibge` | **populacao_2022** | `01_bronze/data/ibge/populacao_2022.parquet` | 5,570 | 3 | 0.07 | 0 |
| `tse` | **bens** | `01_bronze/data/tse/bens.parquet` | 310,847 | 19 | 5.01 | 0 |
| `tse` | **candidatos** | `01_bronze/data/tse/candidatos.parquet` | 151,948 | 50 | 6.20 | 0 |
| `tse` | **despesas** | `01_bronze/data/tse/despesas.parquet` | 1,276,510 | 53 | 64.11 | N/A (>500k) |
| `tse` | **receitas** | `01_bronze/data/tse/receitas.parquet` | 713,921 | 60 | 35.47 | N/A (>500k) |
| `tse` | **votacao** | `01_bronze/data/tse/votacao.parquet` | 254,878 | 50 | 5.29 | 0 |

---

## 2. Alertas de Qualidade (Nulos e Sentinelas TSE/IBGE)

- **`ibge/censo2022_cor_raca_sexo.populacao`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `100.0%` (66,840)
- **`ibge/censo2022_esgotamento_sanitario.pct_domicilios`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `13.95%` (1,554)
- **`ibge/pib_composicao_setorial.valor_mil_reais`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `75.0%` (16,710)
- **`ibge/pib_peso_administracao_publica.percentual`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `100.0%` (11,140)
- **`tse/candidatos.NM_SOCIAL_CANDIDATO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.91%` (151,804)
- **`tse/candidatos.CD_SITUACAO_CANDIDATURA`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `100.0%` (151,948)
- **`tse/candidatos.NR_FEDERACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `85.12%` (129,340)
- **`tse/candidatos.NM_FEDERACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `85.12%` (129,340)
- **`tse/candidatos.SG_FEDERACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `85.12%` (129,340)
- **`tse/candidatos.DS_COMPOSICAO_FEDERACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `85.12%` (129,340)
- **`tse/despesas.CD_CNAE_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `46.01%` (587,281)
- **`tse/despesas.DS_CNAE_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `46.01%` (587,281)
- **`tse/despesas.CD_ESFERA_PART_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `100.0%` (1,276,510)
- **`tse/despesas.DS_ESFERA_PART_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `100.0%` (1,276,510)
- **`tse/despesas.SG_UF_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.51%` (1,270,198)
- **`tse/despesas.CD_MUNICIPIO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.51%` (1,270,296)
- **`tse/despesas.NM_MUNICIPIO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.51%` (1,270,296)
- **`tse/despesas.SQ_CANDIDATO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.58%` (1,271,139)
- **`tse/despesas.NR_CANDIDATO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.57%` (1,271,061)
- **`tse/despesas.CD_CARGO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.57%` (1,271,061)
- **`tse/despesas.DS_CARGO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.57%` (1,271,061)
- **`tse/despesas.NR_PARTIDO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.51%` (1,270,240)
- **`tse/despesas.SG_PARTIDO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.51%` (1,270,240)
- **`tse/despesas.NM_PARTIDO_FORNECEDOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.51%` (1,270,240)
- **`tse/receitas.CD_CNAE_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `53.51%` (381,999)
- **`tse/receitas.DS_CNAE_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `53.51%` (381,999)
- **`tse/receitas.CD_ESFERA_PARTIDARIA_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `85.19%` (608,173)
- **`tse/receitas.DS_ESFERA_PARTIDARIA_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `85.19%` (608,173)
- **`tse/receitas.SG_UF_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `40.96%` (292,447)
- **`tse/receitas.CD_MUNICIPIO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `48.02%` (342,827)
- **`tse/receitas.NM_MUNICIPIO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `48.02%` (342,827)
- **`tse/receitas.SQ_CANDIDATO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `56.81%` (405,556)
- **`tse/receitas.NR_CANDIDATO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `55.77%` (398,167)
- **`tse/receitas.CD_CARGO_CANDIDATO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `55.77%` (398,167)
- **`tse/receitas.DS_CARGO_CANDIDATO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `55.77%` (398,167)
- **`tse/receitas.NR_PARTIDO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `40.99%` (292,606)
- **`tse/receitas.SG_PARTIDO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `40.99%` (292,606)
- **`tse/receitas.NM_PARTIDO_DOADOR`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `40.99%` (292,606)
- **`tse/receitas.NR_RECIBO_DOACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `21.11%` (150,709)
- **`tse/receitas.NR_DOCUMENTO_DOACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `52.86%` (377,379)
- **`tse/receitas.DS_RECEITA`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `51.72%` (369,244)
- **`tse/receitas.DS_NATUREZA_RECURSO_ESTIMAVEL`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `51.73%` (369,321)
- **`tse/votacao.NM_SOCIAL_CANDIDATO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.85%` (254,492)
- **`tse/votacao.CD_SITUACAO_CANDIDATURA`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `100.0%` (254,878)
- **`tse/votacao.CD_DETALHE_SITUACAO_CAND`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `100.0%` (254,878)
- **`tse/votacao.CD_SITUACAO_CASSACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.44%` (253,460)
- **`tse/votacao.DS_SITUACAO_CASSACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.44%` (253,460)
- **`tse/votacao.CD_SITUACAO_DCONST_DIPLOMA`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.99%` (254,864)
- **`tse/votacao.DS_SITUACAO_DCONST_DIPLOMA`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `99.99%` (254,864)
- **`tse/votacao.NR_FEDERACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `84.76%` (216,030)
- **`tse/votacao.NM_FEDERACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `84.76%` (216,030)
- **`tse/votacao.SG_FEDERACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `84.76%` (216,030)
- **`tse/votacao.DS_COMPOSICAO_FEDERACAO`**: Nulos = `0.0%` (0) | Sentinelas (`#NULO#`, `-1`, `...`, etc.) = `84.76%` (216,030)

---

## 3. Perfil Detalhado por Dataset

### 📦 `integracao/depara_tse_ibge` (1,498 linhas × 6 colunas | 0.02 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_tse` | `String` | 0.0% | 0.0% | 1,498 | `40002` | `72737` | `67830` (0.07%); `41033` (0.07%); `62030` (0.07%) |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 1,498 | `3100104` | `3557303` | `3150000` (0.07%); `3510708` (0.07%); `3556354` (0.07%) |
| `codigo_ibge_6` | `String` | 0.0% | 0.0% | 1,498 | `310010` | `355730` | `312590` (0.07%); `314910` (0.07%); `310630` (0.07%) |
| `uf` | `String` | 0.0% | 0.0% | 2 | `MG` | `SP` | `MG` (56.94%); `SP` (43.06%) |
| `nome_municipio_tse` | `String` | 0.0% | 0.0% | 1,493 | `ABADIA DOS DOURADOS` | `ÓLEO` | `ITAPEVA` (0.13%); `TAPIRAÍ` (0.13%); `SÃO FRANCISCO` (0.13%) |
| `capital` | `String` | 0.0% | 0.0% | 2 | `0` | `1` | `0` (99.87%); `1` (0.13%) |

### 📦 `ibge/censo2022_abastecimento_agua` (5,570 linhas × 5 colunas | 0.07 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `1100130` (0.02%); `4304614` (0.02%); `4203600` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `Cristália - MG` (0.02%); `Rio do Pires - BA` (0.02%); `Pinheiro Machado - RS` (0.02%) |
| `ano` | `String` | 0.0% | 0.0% | 1 | `2022` | `2022` | `2022` (100.0%) |
| `forma_abastecimento` | `String` | 0.0% | 0.0% | 1 | `Rede geral de distribuição` | `Rede geral de distribuição` | `Rede geral de distribuição` (100.0%) |
| `pct_rede_geral` | `String` | 0.0% | 0.14% | 3,665 | `0.25` | `99.84` | `83.96` (0.16%); `-` (0.14%); `79.30` (0.13%) |

### 📦 `ibge/censo2022_cor_raca_sexo` (66,840 linhas × 6 colunas | 0.09 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `2602902` (0.02%); `2516706` (0.02%); `3504701` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `Tiradentes do Sul - RS` (0.02%); `São Miguel da Boa Vista - SC` (0.02%); `Cássia dos Coqueiros - SP` (0.02%) |
| `ano` | `String` | 0.0% | 0.0% | 1 | `2022` | `2022` | `2022` (100.0%) |
| `cor_raca` | `String` | 0.0% | 0.0% | 6 | `Amarela` | `Total` | `Total` (16.67%); `Branca` (16.67%); `Preta` (16.67%) |
| `sexo` | `String` | 0.0% | 0.0% | 2 | `Homens` | `Mulheres` | `Homens` (50.0%); `Mulheres` (50.0%) |
| `populacao` | `String` | 0.0% | 100.0% | 1 | `—` | `—` | `...` (100.0%) |

### 📦 `ibge/censo2022_esgotamento_sanitario` (11,140 linhas × 5 colunas | 0.08 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `2210706` (0.02%); `5219357` (0.02%); `2932606` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `Pinhal da Serra - RS` (0.02%); `Ivaté - PR` (0.02%); `Santana do Ipanema - AL` (0.02%) |
| `ano` | `String` | 0.0% | 0.0% | 1 | `2022` | `2022` | `2022` (100.0%) |
| `tipo_esgotamento` | `String` | 0.0% | 0.0% | 2 | `Não tinham banheiro nem sanitário` | `Rede geral, rede pluvial ou fossa ligada à rede` | `Rede geral, rede pluvial ou fossa ligada à rede` (50.0%); `Não tinham banheiro nem sanitário` (50.0%) |
| `pct_domicilios` | `String` | 0.0% | 13.95% | 3,933 | `0.00` | `99.95` | `-` (13.95%); `0.01` (2.64%); `0.02` (2.08%) |

### 📦 `ibge/censo2022_taxa_alfabetizacao` (5,570 linhas × 3 colunas | 0.07 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `2513968` (0.02%); `3123809` (0.02%); `2205805` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `Matos Costa - SC` (0.02%); `Calçoene - AP` (0.02%); `Maracajá - SC` (0.02%) |
| `taxa_alfabetizacao` | `String` | 0.0% | 0.0% | 2,237 | `63.19` | `99.10` | `94.44` (0.18%); `94.49` (0.18%); `94.25` (0.18%) |

### 📦 `ibge/censo2022_urbana_rural` (22,280 linhas × 7 colunas | 0.12 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `3166105` (0.02%); `2607208` (0.02%); `5103452` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `Jandaíra - RN` (0.02%); `Buriti - MA` (0.02%); `Campos Altos - MG` (0.02%) |
| `codigo_variavel` | `String` | 0.0% | 0.0% | 2 | `1000093` | `93` | `93` (50.0%); `1000093` (50.0%) |
| `variavel` | `String` | 0.0% | 0.0% | 2 | `População residente` | `População residente - percentual do total geral` | `População residente` (50.0%); `População residente - percentual do total geral` (50.0%) |
| `ano` | `String` | 0.0% | 0.0% | 1 | `2022` | `2022` | `2022` (100.0%) |
| `situacao_domicilio` | `String` | 0.0% | 0.0% | 2 | `Rural` | `Urbana` | `Urbana` (50.0%); `Rural` (50.0%) |
| `valor` | `String` | 0.0% | 0.29% | 14,491 | `0.00` | `9982` | `-` (0.29%); `100.00` (0.17%); `941` (0.04%) |

### 📦 `ibge/pib_composicao_setorial` (22,280 linhas × 6 colunas | 0.09 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `2502300` (0.02%); `2510501` (0.02%); `5214903` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `São Pedro do Piauí - PI` (0.02%); `Joselândia - MA` (0.02%); `Baraúna - RN` (0.02%) |
| `ano` | `String` | 0.0% | 0.0% | 1 | `2023` | `2023` | `2023` (100.0%) |
| `codigo_variavel` | `String` | 0.0% | 0.0% | 4 | `37` | `525` | `37` (25.0%); `514` (25.0%); `525` (25.0%) |
| `variavel` | `String` | 0.0% | 0.0% | 4 | `Participação do valor adicionado bruto a preç...` | `Valor adicionado bruto a preços correntes da ...` | `Produto Interno Bruto a preços correntes` (25.0%); `Participação do valor adicionado bruto a preç...` (25.0%); `Valor adicionado bruto a preços correntes da ...` (25.0%) |
| `valor_mil_reais` | `String` | 0.0% | 75.0% | 5,552 | `100032` | `99886` | `...` (75.0%); `129242` (0.01%); `134732` (0.01%) |

### 📦 `ibge/pib_municipal` (5,570 linhas × 4 colunas | 0.07 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `4106506` (0.02%); `3506359` (0.02%); `1715705` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `Gurinhém - PB` (0.02%); `Porto Feliz - SP` (0.02%); `São José do Sul - RS` (0.02%) |
| `pib` | `String` | 0.0% | 0.0% | 5,551 | `100032.0` | `99886.0` | `164342.0` (0.04%); `113862.0` (0.04%); `159894.0` (0.04%) |
| `ano_pib` | `String` | 0.0% | 0.0% | 1 | `2023` | `2023` | `2023` (100.0%) |

### 📦 `ibge/pib_peso_administracao_publica` (11,140 linhas × 6 colunas | 0.06 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `3112653` (0.02%); `1506906` (0.02%); `3157658` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `Ortigueira - PR` (0.02%); `Peritoró - MA` (0.02%); `Barracão - RS` (0.02%) |
| `ano` | `String` | 0.0% | 0.0% | 1 | `2023` | `2023` | `2023` (100.0%) |
| `codigo_variavel` | `String` | 0.0% | 0.0% | 2 | `526` | `527` | `526` (50.0%); `527` (50.0%) |
| `indicador` | `String` | 0.0% | 0.0% | 2 | `Participação do valor adicionado bruto a preç...` | `Participação do valor adicionado bruto a preç...` | `Participação do valor adicionado bruto a preç...` (50.0%); `Participação do valor adicionado bruto a preç...` (50.0%) |
| `percentual` | `String` | 0.0% | 100.0% | 1 | `—` | `—` | `...` (100.0%) |

### 📦 `ibge/populacao_2022` (5,570 linhas × 3 colunas | 0.07 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `codigo_ibge` | `String` | 0.0% | 0.0% | 5,570 | `1100015` | `5300108` | `5215405` (0.02%); `3154507` (0.02%); `2927408` (0.02%) |
| `nome_municipio` | `String` | 0.0% | 0.0% | 5,570 | `Abadia de Goiás - GO` | `Óleo - SP` | `São Sebastião da Bela Vista - MG` (0.02%); `Turvo - SC` (0.02%); `Bernardino Batista - PB` (0.02%) |
| `populacao` | `String` | 0.0% | 0.0% | 5,069 | `10007` | `9972` | `4841` (0.07%); `5228` (0.07%); `4127` (0.07%) |

### 📦 `tse/bens` (310,847 linhas × 19 colunas | 5.01 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `DT_GERACAO` | `String` | 0.0% | 0.0% | 1 | `13/11/2026` | `13/11/2026` | `13/11/2026` (100.0%) |
| `HH_GERACAO` | `String` | 0.0% | 0.0% | 1 | `02:15:36` | `02:15:36` | `02:15:36` (100.0%) |
| `ANO_ELEICAO` | `String` | 0.0% | 0.0% | 1 | `2024` | `2024` | `2024` (100.0%) |
| `CD_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `2` (99.82%); `1` (0.18%) |
| `NM_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `Eleição Ordinária` | `Eleição Suplementar` | `Eleição Ordinária` (99.82%); `Eleição Suplementar` (0.18%) |
| `CD_ELEICAO` | `String` | 0.0% | 0.0% | 26 | `6041` | `6302` | `619` (99.82%); `6200` (0.02%); `6180` (0.01%) |
| `DS_ELEICAO` | `String` | 0.0% | 0.0% | 26 | `Eleição Supl Santo Antônio Rio Abaixo` | `Suplementar de Narandiba - out/26` | `Eleições Municipais 2024` (99.82%); `Eleição suplementar Guapé` (0.02%); `Eleição Suplementar de Mongaguá` (0.01%) |
| `DT_ELEICAO` | `String` | 0.0% | 0.0% | 11 | `03/08/2025` | `25/10/2026` | `06/10/2024` (99.82%); `06/12/2026` (0.04%); `08/06/2025` (0.03%) |
| `SG_UF` | `String` | 0.0% | 0.0% | 2 | `MG` | `SP` | `SP` (50.8%); `MG` (49.2%) |
| `SG_UE` | `String` | 0.0% | 0.0% | 1,498 | `40002` | `72737` | `71072` (1.11%); `41238` (0.55%); `62910` (0.46%) |
| `NM_UE` | `String` | 0.0% | 0.0% | 1,493 | `ABADIA DOS DOURADOS` | `ÓLEO` | `SÃO PAULO` (1.11%); `BELO HORIZONTE` (0.55%); `CAMPINAS` (0.46%) |
| `SQ_CANDIDATO` | `String` | 0.0% | 0.0% | 100,971 | `130001880123` | `250002554944` | `250001971403` (0.05%); `250002347038` (0.04%); `130002012266` (0.03%) |
| `NR_ORDEM_BEM_CANDIDATO` | `String` | 0.0% | 0.0% | 162 | `1` | `99` | `1` (32.48%); `2` (21.24%); `3` (13.33%) |
| `CD_TIPO_BEM_CANDIDATO` | `String` | 0.0% | 0.0% | 50 | `1` | `99` | `21` (33.7%); `12` (15.35%); `13` (8.82%) |
| `DS_TIPO_BEM_CANDIDATO` | `String` | 0.0% | 0.0% | 50 | `Aeronave` | `Veículo automotor terrestre: caminhão, automó...` | `Veículo automotor terrestre: caminhão, automó...` (33.7%); `Casa` (15.35%); `Terreno` (8.82%) |
| `DS_BEM_CANDIDATO` | `String` | 0.0% | 0.18% | 183,208 | `10ha TERRENO RURAL` | `única proprietária por declaração de compra e...` | `CARRO` (1.27%); `CASA` (1.02%); `DINHEIRO EM ESPECIE` (0.82%) |
| `VR_BEM_CANDIDATO` | `String` | 0.0% | 0.0% | 75,570 | `0,00` | `99999,90` | `10000,00` (2.71%); `100000,00` (2.38%); `20000,00` (2.3%) |
| `DT_ULT_ATUAL_BEM_CANDIDATO` | `String` | 0.0% | 0.0% | 32 | `01/10/2026` | `29/10/2026` | `07/07/2026` (96.1%); `29/10/2026` (0.67%); `08/09/2026` (0.63%) |
| `HH_ULT_ATUAL_BEM_CANDIDATO` | `String` | 0.0% | 0.0% | 2,776 | `09:32:58` | `22:15:43` | `15:06:22` (0.13%); `15:18:26` (0.12%); `15:08:33` (0.12%) |

### 📦 `tse/candidatos` (151,948 linhas × 50 colunas | 6.20 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `DT_GERACAO` | `String` | 0.0% | 0.0% | 1 | `13/11/2026` | `13/11/2026` | `13/11/2026` (100.0%) |
| `HH_GERACAO` | `String` | 0.0% | 0.0% | 1 | `02:15:37` | `02:15:37` | `02:15:37` (100.0%) |
| `ANO_ELEICAO` | `String` | 0.0% | 0.0% | 1 | `2024` | `2024` | `2024` (100.0%) |
| `CD_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `2` (99.91%); `1` (0.09%) |
| `NM_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `ELEIÇÃO ORDINÁRIA` | `ELEIÇÃO SUPLEMENTAR` | `ELEIÇÃO ORDINÁRIA` (99.91%); `ELEIÇÃO SUPLEMENTAR` (0.09%) |
| `NR_TURNO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `1` (99.95%); `2` (0.05%) |
| `CD_ELEICAO` | `String` | 0.0% | 0.0% | 27 | `6041` | `6302` | `619` (99.86%); `620` (0.05%); `6297` (0.01%) |
| `DS_ELEICAO` | `String` | 0.0% | 0.0% | 26 | `Eleição Supl Santo Antônio Rio Abaixo` | `Suplementar de Narandiba - out/26` | `Eleições Municipais 2024` (99.91%); `Eleição Suplementar Francisco Sá` (0.01%); `Eleição Suplementar de Bocaina` (0.01%) |
| `DT_ELEICAO` | `String` | 0.0% | 0.0% | 12 | `03/08/2025` | `27/10/2024` | `06/10/2024` (99.86%); `27/10/2024` (0.05%); `06/12/2026` (0.02%) |
| `TP_ABRANGENCIA` | `String` | 0.0% | 0.0% | 1 | `MUNICIPAL` | `MUNICIPAL` | `MUNICIPAL` (100.0%) |
| `SG_UF` | `String` | 0.0% | 0.0% | 2 | `MG` | `SP` | `SP` (51.63%); `MG` (48.37%) |
| `SG_UE` | `String` | 0.0% | 0.0% | 1,498 | `40002` | `72737` | `71072` (0.68%); `41238` (0.59%); `64777` (0.43%) |
| `NM_UE` | `String` | 0.0% | 0.0% | 1,493 | `ABADIA DOS DOURADOS` | `ÓLEO` | `SÃO PAULO` (0.68%); `BELO HORIZONTE` (0.59%); `GUARULHOS` (0.43%) |
| `CD_CARGO` | `String` | 0.0% | 0.0% | 3 | `11` | `13` | `13` (93.97%); `12` (3.04%); `11` (2.99%) |
| `DS_CARGO` | `String` | 0.0% | 0.0% | 3 | `PREFEITO` | `VICE-PREFEITO` | `VEREADOR` (93.97%); `VICE-PREFEITO` (3.04%); `PREFEITO` (2.99%) |
| `SQ_CANDIDATO` | `String` | 0.0% | 0.0% | 151,868 | `130001880122` | `250002554944` | `250002122395` (0.0%); `250001953266` (0.0%); `250002256485` (0.0%) |
| `NR_CANDIDATO` | `String` | 0.0% | 0.0% | 11,117 | `10` | `80800` | `55` (0.91%); `55555` (0.71%); `55123` (0.7%) |
| `NM_CANDIDATO` | `String` | 0.0% | 0.0% | 146,926 | `ANANIAS TAVARES DE SOUZA` | `ÓLIVER ALONSO DELLA MATTA SILVA` | `MARIA APARECIDA DA SILVA` (0.02%); `JOSÉ CARLOS DA SILVA` (0.02%); `JOÃO BATISTA DA SILVA` (0.02%) |
| `NM_URNA_CANDIDATO` | `String` | 0.0% | 0.0% | 130,328 | `JC  CESAR DE RITA DE BEG` | `Ú FONSECA` | `PAULINHO` (0.04%); `FABINHO` (0.04%); `ANA PAULA` (0.04%) |
| `NM_SOCIAL_CANDIDATO` | `String` | 0.0% | 99.91% | 127 | `AGATHA BEATRIZ FELIX DE SOUZA` | `ZYDARA LOPEZ` | `#NULO` (99.91%); `NÃO DIVULGÁVEL` (0.01%); `JAQUELINE` (0.0%) |
| `NR_CPF_CANDIDATO` | `String` | 0.0% | 0.0% | 1 | `-4` | `-4` | `-4` (100.0%) |
| `DS_EMAIL` | `String` | 0.0% | 0.0% | 1 | `NÃO DIVULGÁVEL` | `NÃO DIVULGÁVEL` | `NÃO DIVULGÁVEL` (100.0%) |
| `CD_SITUACAO_CANDIDATURA` | `String` | 0.0% | 100.0% | 1 | `—` | `—` | `-3` (100.0%) |
| `DS_SITUACAO_CANDIDATURA` | `String` | 0.0% | 0.0% | 1 | `#NE` | `#NE` | `#NE` (100.0%) |
| `TP_AGREMIACAO` | `String` | 0.0% | 0.0% | 3 | `COLIGAÇÃO` | `PARTIDO ISOLADO` | `PARTIDO ISOLADO` (81.21%); `FEDERAÇÃO` (14.25%); `COLIGAÇÃO` (4.54%) |
| `NR_PARTIDO` | `String` | 0.0% | 0.0% | 29 | `10` | `80` | `55` (8.83%); `22` (7.98%); `10` (7.92%) |
| `SG_PARTIDO` | `String` | 0.0% | 0.0% | 30 | `AGIR` | `UP` | `PSD` (8.83%); `PL` (7.98%); `REPUBLICANOS` (7.92%) |
| `NM_PARTIDO` | `String` | 0.0% | 0.0% | 30 | `AGIR` | `UNIÃO BRASIL` | `PARTIDO SOCIAL DEMOCRÁTICO` (8.83%); `PARTIDO LIBERAL` (7.98%); `REPUBLICANOS` (7.92%) |
| `NR_FEDERACAO` | `String` | 0.0% | 85.12% | 6 | `100` | `104` | `-1` (85.12%); `101` (6.76%); `100` (6.06%) |
| `NM_FEDERACAO` | `String` | 0.0% | 85.12% | 8 | `FEDERAÇÃO BRASIL DA ESPERANÇA - FE BRASIL` | `Federação PSOL REDE` | `#NULO` (85.12%); `Federação BRASIL DA ESPERANÇA - FE BRASIL` (6.76%); `Federação PSDB CIDADANIA` (6.06%) |
| `SG_FEDERACAO` | `String` | 0.0% | 85.12% | 10 | `13-PT/65-PC do B/43-PV` | `UNIÃO/PP` | `#NULO` (85.12%); `13-PT/65-PC do B/43-PV` (6.76%); `45-PSDB/23-CIDADANIA` (6.06%) |
| `DS_COMPOSICAO_FEDERACAO` | `String` | 0.0% | 85.12% | 10 | `13-PT/65-PC do B/43-PV` | `UNIÃO/PP` | `#NULO` (85.12%); `13-PT/65-PC do B/43-PV` (6.76%); `45-PSDB/23-CIDADANIA` (6.06%) |
| `SQ_COLIGACAO` | `String` | 0.0% | 0.0% | 17,307 | `130001687199` | `250001802167` | `250001730716` (0.04%); `250001734269` (0.04%); `250001702010` (0.04%) |
| `NM_COLIGACAO` | `String` | 0.0% | 0.0% | 3,084 | `A VERDADEIRA RENOVAÇÃO DE PANORAMA` | `É TEMPO DE MUDANÇA. SÃO JOSÉ DO BARREIRO PODE...` | `PARTIDO ISOLADO` (81.21%); `FEDERAÇÃO` (14.25%); `JUNTOS SOMOS MAIS FORTES` (0.04%) |
| `DS_COMPOSICAO_COLIGACAO` | `String` | 0.0% | 0.0% | 2,281 | `AGIR` | `UP` | `PSD` (8.17%); `PL` (7.51%); `REPUBLICANOS` (7.49%) |
| `SG_UF_NASCIMENTO` | `String` | 0.0% | 0.0% | 29 | `AC` | `ZZ` | `MG` (46.04%); `SP` (43.99%); `PR` (2.29%) |
| `DT_NASCIMENTO` | `String` | 0.01% | 0.0% | 20,660 | `01/01/1945` | `31/12/2003` | `02/07/1978` (0.02%); `05/11/1969` (0.02%); `02/07/1975` (0.02%) |
| `NR_TITULO_ELEITORAL_CANDIDATO` | `String` | 0.0% | 0.0% | 151,581 | `-4` | `493855360108` | `-4` (0.01%); `372402590132` (0.0%); `261900350183` (0.0%) |
| `CD_GENERO` | `String` | 0.0% | 0.0% | 3 | `-4` | `4` | `2` (66.09%); `4` (33.9%); `-4` (0.01%) |
| `DS_GENERO` | `String` | 0.0% | 0.0% | 3 | `FEMININO` | `NÃO DIVULGÁVEL` | `MASCULINO` (66.09%); `FEMININO` (33.9%); `NÃO DIVULGÁVEL` (0.01%) |
| `CD_GRAU_INSTRUCAO` | `String` | 0.0% | 0.0% | 9 | `-4` | `8` | `6` (38.77%); `8` (27.73%); `4` (11.45%) |
| `DS_GRAU_INSTRUCAO` | `String` | 0.0% | 0.0% | 9 | `ANALFABETO` | `SUPERIOR INCOMPLETO` | `ENSINO MÉDIO COMPLETO` (38.77%); `SUPERIOR COMPLETO` (27.73%); `ENSINO FUNDAMENTAL COMPLETO` (11.45%) |
| `CD_ESTADO_CIVIL` | `String` | 0.0% | 0.0% | 6 | `-4` | `9` | `3` (53.12%); `1` (32.35%); `9` (11.27%) |
| `DS_ESTADO_CIVIL` | `String` | 0.0% | 0.0% | 6 | `CASADO(A)` | `VIÚVO(A)` | `CASADO(A)` (53.12%); `SOLTEIRO(A)` (32.35%); `DIVORCIADO(A)` (11.27%) |
| `CD_COR_RACA` | `String` | 0.0% | 0.0% | 7 | `-4` | `06` | `01` (55.65%); `03` (31.49%); `02` (11.69%) |
| `DS_COR_RACA` | `String` | 0.0% | 0.0% | 7 | `AMARELA` | `PRETA` | `BRANCA` (55.65%); `PARDA` (31.49%); `PRETA` (11.69%) |
| `CD_OCUPACAO` | `String` | 0.0% | 0.0% | 245 | `-4` | `999` | `999` (23.39%); `257` (7.49%); `298` (7.35%) |
| `DS_OCUPACAO` | `String` | 0.0% | 0.0% | 245 | `ADMINISTRADORA/ADMINISTRADOR` | `ZOOTECNISTA` | `OUTROS` (23.39%); `EMPRESÁRIA/EMPRESÁRIO` (7.49%); `SERVIDOR PÚBLICO MUNICIPAL` (7.35%) |
| `CD_SIT_TOT_TURNO` | `String` | 0.0% | 2.65% | 7 | `1` | `6` | `5` (51.02%); `4` (34.06%); `2` (6.39%) |
| `DS_SIT_TOT_TURNO` | `String` | 0.0% | 2.65% | 7 | `2º TURNO` | `SUPLENTE` | `SUPLENTE` (51.02%); `NÃO ELEITO` (34.06%); `ELEITO POR QP` (6.39%) |

### 📦 `tse/despesas` (1,276,510 linhas × 53 colunas | 64.11 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `DT_GERACAO` | `String` | 0.0% | 0.0% | 1 | `15/11/2026` | `15/11/2026` | `15/11/2026` (100.0%) |
| `HH_GERACAO` | `String` | 0.0% | 0.0% | 1 | `23:00:15` | `23:00:15` | `23:00:15` (100.0%) |
| `AA_ELEICAO` | `String` | 0.0% | 0.0% | 1 | `2024` | `2024` | `2024` (100.0%) |
| `CD_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `2` (99.83%); `1` (0.17%) |
| `NM_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `Ordinária` | `Suplementar` | `Ordinária` (99.83%); `Suplementar` (0.17%) |
| `CD_ELEICAO` | `String` | 0.0% | 0.0% | 20 | `6041` | `6284` | `619` (99.83%); `6042` (0.03%); `6180` (0.02%) |
| `DS_ELEICAO` | `String` | 0.0% | 0.0% | 20 | `Eleição Supl. São José da Varginha` | `Suplementar de Narandiba - out/26` | `Eleições Municipais 2024` (99.83%); `Eleição Suplementar de Eldorado` (0.03%); `Eleição Suplementar de Mongaguá` (0.02%) |
| `DT_ELEICAO` | `String` | 0.0% | 0.0% | 10 | `03/08/2025` | `25/10/2026` | `06/10/2024` (99.83%); `08/06/2025` (0.04%); `06/04/2025` (0.03%) |
| `ST_TURNO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `1` (96.36%); `2` (3.64%) |
| `TP_PRESTACAO_CONTAS` | `String` | 0.0% | 0.0% | 4 | `Final` | `Relatório Financeiro` | `Final` (99.8%); `Parcial` (0.07%); `Regularização da Omissão` (0.07%) |
| `DT_PRESTACAO_CONTAS` | `String` | 0.0% | 0.0% | 577 | `01/01/2025` | `31/12/2024` | `05/11/2024` (19.33%); `04/11/2024` (7.77%); `01/11/2024` (3.99%) |
| `SQ_PRESTADOR_CONTAS` | `String` | 0.0% | 0.0% | 146,697 | `5228010770` | `6883737448` | `5250793262` (0.81%); `5260175458` (0.45%); `5249046393` (0.31%) |
| `SG_UF` | `String` | 0.0% | 0.0% | 2 | `MG` | `SP` | `SP` (55.91%); `MG` (44.09%) |
| `SG_UE` | `String` | 0.0% | 0.0% | 1,498 | `40002` | `72737` | `71072` (6.43%); `41238` (3.44%); `64777` (1.48%) |
| `NM_UE` | `String` | 0.0% | 0.0% | 1,493 | `ABADIA DOS DOURADOS` | `ÓLEO` | `SÃO PAULO` (6.43%); `BELO HORIZONTE` (3.44%); `GUARULHOS` (1.48%) |
| `NR_CNPJ_PRESTADOR_CONTA` | `String` | 0.0% | 0.0% | 146,697 | `56064853000141` | `69503446000135` | `56233510000163` (0.81%); `56324323000195` (0.45%); `56205815000161` (0.31%) |
| `CD_CARGO` | `String` | 0.0% | 0.0% | 3 | `11` | `13` | `13` (58.98%); `11` (41.02%); `12` (0.0%) |
| `DS_CARGO` | `String` | 0.0% | 0.0% | 3 | `Prefeito` | `Vice-prefeito` | `Vereador` (58.98%); `Prefeito` (41.02%); `Vice-prefeito` (0.0%) |
| `SQ_CANDIDATO` | `String` | 0.0% | 0.0% | 146,697 | `130001880122` | `250002554763` | `250001926547` (0.81%); `130001975610` (0.45%); `250001918263` (0.31%) |
| `NR_CANDIDATO` | `String` | 0.0% | 0.0% | 11,080 | `10` | `80800` | `55` (6.53%); `22` (5.77%); `10` (4.25%) |
| `NM_CANDIDATO` | `String` | 0.0% | 0.0% | 142,131 | `045.850.346-09` | `ÓLIVER ALONSO DELLA MATTA SILVA` | `GUILHERME CASTRO BOULOS` (0.81%); `FUAD JORGE NOMAN FILHO` (0.45%); `DÁRIO JORGE GIOLO SAADI` (0.31%) |
| `NR_CPF_CANDIDATO` | `String` | 0.0% | 0.0% | 1 | `-4` | `-4` | `-4` (100.0%) |
| `NR_CPF_VICE_CANDIDATO` | `String` | 0.0% | 0.0% | 1 | `-4` | `-4` | `-4` (100.0%) |
| `NR_PARTIDO` | `String` | 0.0% | 0.0% | 29 | `10` | `80` | `22` (13.52%); `55` (11.44%); `13` (9.82%) |
| `SG_PARTIDO` | `String` | 0.0% | 0.0% | 29 | `AGIR` | `UP` | `PL` (13.52%); `PSD` (11.44%); `PT` (9.82%) |
| `NM_PARTIDO` | `String` | 0.0% | 0.0% | 41 | `AGIR` | `União Brasil` | `Partido Liberal` (13.51%); `Partido Social Democrático` (11.43%); `Partido dos Trabalhadores` (9.8%) |
| `CD_TIPO_FORNECEDOR` | `String` | 0.0% | 5.53% | 3 | `0` | `1` | `1` (57.4%); `0` (37.07%); `-1` (5.53%) |
| `DS_TIPO_FORNECEDOR` | `String` | 0.0% | 5.53% | 3 | `PESSOA FÍSICA` | `PESSOA JURÍDICA` | `PESSOA JURÍDICA` (57.4%); `PESSOA FÍSICA` (37.07%); `#NULO` (5.53%) |
| `CD_CNAE_FORNECEDOR` | `String` | 0.0% | 46.01% | 407 | `01130` | `97005` | `-1` (46.01%); `18130` (12.49%); `73122` (3.28%) |
| `DS_CNAE_FORNECEDOR` | `String` | 0.0% | 46.01% | 407 | `Acabamentos em fios, tecidos e artefatos têxteis` | `Trens turísticos, teleféricos e similares` | `#NULO` (46.01%); `Impressão de materiais para outros usos` (12.49%); `Agenciamento de espaços para publicidade, exc...` (3.28%) |
| `NR_CPF_CNPJ_FORNECEDOR` | `String` | 0.0% | 8.76% | 455,300 | `00000000000` | `99999999999` | `-1` (8.76%); `13347016000117` (2.88%); `08142850000136` (0.69%) |
| `NM_FORNECEDOR` | `String` | 0.0% | 8.76% | 470,992 | `,CALLEU HENRIQUE COSME ROMUALDO` | `ÚLTIMA LEITE DA ROCHA` | `#NULO` (8.76%); `FACEBOOK SERVICOS ONLINE DO BRASIL LTDA` (0.76%); `FACEBOOK SERVIÇOS ONLINE DO BRASIL LTDA` (0.73%) |
| `NM_FORNECEDOR_RFB` | `String` | 0.0% | 8.76% | 435,082 | `00` | `ZYON MAXIMILIANO GUIMARAES` | `#NULO` (8.76%); `FACEBOOK SERVICOS ONLINE DO BRASIL LTDA.` (2.88%); `WBL GRAFICA E EDITORA LTDA` (0.69%) |
| `CD_ESFERA_PART_FORNECEDOR` | `String` | 0.0% | 100.0% | 1 | `—` | `—` | `-1` (100.0%) |
| `DS_ESFERA_PART_FORNECEDOR` | `String` | 0.0% | 100.0% | 1 | `—` | `—` | `#NULO` (100.0%) |
| `SG_UF_FORNECEDOR` | `String` | 0.0% | 99.51% | 8 | `BR` | `SP` | `#NULO#` (99.51%); `SP` (0.25%); `MG` (0.24%) |
| `CD_MUNICIPIO_FORNECEDOR` | `String` | 0.0% | 99.51% | 589 | `17612` | `81051` | `-1` (99.51%); `70750` (0.04%); `41238` (0.02%) |
| `NM_MUNICIPIO_FORNECEDOR` | `String` | 0.0% | 99.51% | 588 | `ADAMANTINA` | `ÁLVARO DE CARVALHO` | `#NULO` (99.51%); `SÃO BERNARDO DO CAMPO` (0.04%); `BELO HORIZONTE` (0.02%) |
| `SQ_CANDIDATO_FORNECEDOR` | `String` | 0.0% | 99.58% | 4,240 | `130001880224` | `250002400849` | `-1` (99.58%); `130002024322` (0.0%); `130002132520` (0.0%) |
| `NR_CANDIDATO_FORNECEDOR` | `String` | 0.0% | 99.57% | 1,541 | `10` | `77999` | `-1` (99.57%); `13123` (0.0%); `13000` (0.0%) |
| `CD_CARGO_FORNECEDOR` | `String` | 0.0% | 99.57% | 4 | `11` | `13` | `-1` (99.57%); `13` (0.41%); `11` (0.01%) |
| `DS_CARGO_FORNECEDOR` | `String` | 0.0% | 99.57% | 4 | `Prefeito` | `Vice-prefeito` | `#NULO` (99.57%); `Vereador` (0.41%); `Prefeito` (0.01%) |
| `NR_PARTIDO_FORNECEDOR` | `String` | 0.0% | 99.51% | 28 | `10` | `80` | `-1` (99.51%); `22` (0.05%); `13` (0.05%) |
| `SG_PARTIDO_FORNECEDOR` | `String` | 0.0% | 99.51% | 28 | `AGIR` | `UP` | `#NULO` (99.51%); `PL` (0.05%); `PT` (0.05%) |
| `NM_PARTIDO_FORNECEDOR` | `String` | 0.0% | 99.51% | 28 | `AGIR` | `União Brasil` | `#NULO` (99.51%); `Partido Liberal` (0.05%); `Partido dos Trabalhadores` (0.05%) |
| `DS_TIPO_DOCUMENTO` | `String` | 0.0% | 9.21% | 8 | `Cupom Fiscal` | `Recibo` | `Nota Fiscal` (47.39%); `Outro` (35.61%); `#NULO` (9.21%) |
| `NR_DOCUMENTO` | `String` | 0.0% | 9.21% | 129,271 | `0` | `u` | `SN` (10.41%); `#NULO#` (9.21%); `1` (2.91%) |
| `CD_ORIGEM_DESPESA` | `String` | 0.0% | 5.53% | 42 | `20010000` | `20900000` | `20140000` (25.08%); `20800000` (16.55%); `20010000` (14.81%) |
| `DS_ORIGEM_DESPESA` | `String` | 0.0% | 5.53% | 42 | `Alimentação` | `Água` | `Publicidade por materiais impressos` (25.08%); `Atividades de militância e mobilização de rua` (16.55%); `Despesas com pessoal` (14.81%) |
| `SQ_DESPESA` | `String` | 0.0% | 5.53% | 857,658 | `53552662` | `81692190` | `-1` (5.53%); `72875003` (0.04%); `64624244` (0.02%) |
| `DT_DESPESA` | `String` | 5.53% | 0.0% | 397 | `01/01/2024` | `31/12/2024` | `09/09/2024` (6.39%); `<NULL>` (5.53%); `16/08/2024` (4.49%) |
| `DS_DESPESA` | `String` | 0.0% | 5.98% | 452,848 | `( SOLIDARIEDADE) ADESIVO PARACHOQUE 0,30X0,10` | `ÔNIBUS M. BENZ / O 371 RSD ANO 1993/1993 KTH2F92` | `#NULO` (5.98%); `CABO ELEITORAL` (2.42%); `PANFLETAGEM` (1.76%) |
| `VR_DESPESA_CONTRATADA` | `String` | 0.0% | 0.0% | 59,404 | `0,00` | `9999,99` | `0,00` (5.53%); `1000,00` (3.89%); `500,00` (3.75%) |

### 📦 `tse/receitas` (713,921 linhas × 60 colunas | 35.47 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `DT_GERACAO` | `String` | 0.0% | 0.0% | 1 | `15/11/2026` | `15/11/2026` | `15/11/2026` (100.0%) |
| `HH_GERACAO` | `String` | 0.0% | 0.0% | 1 | `23:00:17` | `23:00:17` | `23:00:17` (100.0%) |
| `AA_ELEICAO` | `String` | 0.0% | 0.0% | 1 | `2024` | `2024` | `2024` (100.0%) |
| `CD_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `2` (99.96%); `1` (0.04%) |
| `NM_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `ORDINÁRIA` | `SUPLEMENTAR` | `ORDINÁRIA` (99.96%); `SUPLEMENTAR` (0.04%) |
| `CD_ELEICAO` | `String` | 0.0% | 0.0% | 20 | `6041` | `6284` | `619` (99.96%); `6237` (0.01%); `6200` (0.01%) |
| `DS_ELEICAO` | `String` | 0.0% | 0.0% | 20 | `Eleição Supl. São José da Varginha` | `Suplementar de Narandiba - out/26` | `Eleições Municipais 2024` (99.96%); `Eleição Supl. São José da Varginha` (0.01%); `Eleição suplementar Guapé` (0.01%) |
| `DT_ELEICAO` | `String` | 0.0% | 0.0% | 10 | `03/08/2025` | `25/10/2026` | `06/10/2024` (99.96%); `21/06/2026` (0.01%); `03/08/2025` (0.01%) |
| `ST_TURNO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `1` (99.64%); `2` (0.36%) |
| `TP_PRESTACAO_CONTAS` | `String` | 0.0% | 0.0% | 4 | `FINAL` | `RELATÓRIO FINANCEIRO` | `FINAL` (99.73%); `PARCIAL` (0.12%); `REGULARIZAÇÃO DA OMISSÃO` (0.08%) |
| `DT_PRESTACAO_CONTAS` | `String` | 0.0% | 0.0% | 577 | `01/01/2025` | `31/12/2024` | `05/11/2024` (16.56%); `27/11/2024` (16.14%); `04/11/2024` (6.42%) |
| `SQ_PRESTADOR_CONTAS` | `String` | 0.0% | 0.0% | 146,693 | `5228010770` | `6883737448` | `5260873705` (15.75%); `5267629965` (0.06%); `5267769216` (0.06%) |
| `SG_UF` | `String` | 0.0% | 0.0% | 2 | `MG` | `SP` | `SP` (55.48%); `MG` (44.52%) |
| `SG_UE` | `String` | 0.0% | 0.0% | 1,498 | `40002` | `72737` | `71072` (17.19%); `41238` (1.07%); `64777` (0.64%) |
| `NM_UE` | `String` | 0.0% | 0.0% | 1,493 | `ABADIA DOS DOURADOS` | `ÓLEO` | `SÃO PAULO` (17.19%); `BELO HORIZONTE` (1.07%); `GUARULHOS` (0.64%) |
| `NR_CNPJ_PRESTADOR_CONTA` | `String` | 0.0% | 0.0% | 146,693 | `56064853000141` | `69503446000135` | `56336422000197` (15.75%); `56515746000192` (0.06%); `56483526000124` (0.06%) |
| `CD_CARGO` | `String` | 0.0% | 0.0% | 3 | `11` | `13` | `13` (76.47%); `11` (23.53%); `12` (0.0%) |
| `DS_CARGO` | `String` | 0.0% | 0.0% | 3 | `Prefeito` | `Vice-prefeito` | `Vereador` (76.47%); `Prefeito` (23.53%); `Vice-prefeito` (0.0%) |
| `SQ_CANDIDATO` | `String` | 0.0% | 0.0% | 146,693 | `130001880122` | `250002554763` | `250001978066` (15.75%); `250002034123` (0.06%); `250002047349` (0.06%) |
| `NR_CANDIDATO` | `String` | 0.0% | 0.0% | 11,080 | `10` | `80800` | `28` (15.78%); `55` (1.12%); `13` (0.86%) |
| `NM_CANDIDATO` | `String` | 0.0% | 0.0% | 142,135 | `045.850.346-09` | `ÓLIVER ALONSO DELLA MATTA SILVA` | `PABLO HENRIQUE COSTA MARCAL` (15.75%); `YE YONG YONG` (0.06%); `JOSÉ DE FILIPPI JUNIOR` (0.06%) |
| `NR_CPF_CANDIDATO` | `String` | 0.0% | 0.0% | 1 | `-4` | `-4` | `-4` (100.0%) |
| `NR_CPF_VICE_CANDIDATO` | `String` | 0.0% | 0.0% | 1 | `-4` | `-4` | `-4` (100.0%) |
| `NR_PARTIDO` | `String` | 0.0% | 0.0% | 29 | `10` | `80` | `28` (16.66%); `55` (7.79%); `15` (6.84%) |
| `SG_PARTIDO` | `String` | 0.0% | 0.0% | 29 | `AGIR` | `UP` | `PRTB` (16.66%); `PSD` (7.79%); `MDB` (6.84%) |
| `NM_PARTIDO` | `String` | 0.0% | 0.0% | 41 | `AGIR` | `União Brasil` | `Partido Renovador Trabalhista Brasileiro` (16.66%); `Partido Social Democrático` (7.79%); `Movimento Democrático Brasileiro` (6.84%) |
| `CD_FONTE_RECEITA` | `String` | 0.0% | 4.13% | 4 | `0` | `2` | `1` (75.21%); `2` (19.76%); `-1` (4.13%) |
| `DS_FONTE_RECEITA` | `String` | 0.0% | 4.13% | 4 | `FUNDO ESPECIAL` | `OUTROS RECURSOS` | `OUTROS RECURSOS` (75.21%); `FUNDO ESPECIAL` (19.76%); `#NULO` (4.13%) |
| `CD_ORIGEM_RECEITA` | `String` | 0.0% | 4.13% | 11 | `10010100` | `10040000` | `10040000` (31.5%); `10010200` (24.09%); `10020000` (14.81%) |
| `DS_ORIGEM_RECEITA` | `String` | 0.0% | 4.13% | 11 | `Comercialização de Bens com FEFC` | `Rendimentos de aplicações financeiras` | `Recursos de outros candidatos` (31.5%); `Recursos de pessoas físicas` (24.09%); `Recursos de partido político` (14.81%) |
| `CD_NATUREZA_RECEITA` | `String` | 0.0% | 0.0% | 2 | `0` | `1` | `1` (51.74%); `0` (48.26%) |
| `DS_NATUREZA_RECEITA` | `String` | 0.0% | 0.0% | 2 | `ESTIMÁVEL` | `FINANCEIRO` | `FINANCEIRO` (51.74%); `ESTIMÁVEL` (48.26%) |
| `CD_ESPECIE_RECEITA` | `String` | 0.0% | 4.13% | 13 | `0` | `9` | `2` (48.26%); `19` (35.31%); `1` (8.56%) |
| `DS_ESPECIE_RECEITA` | `String` | 0.0% | 4.13% | 13 | `--` | `Transferência eletrônica` | `Estimado` (48.26%); `PIX` (35.31%); `Transferência eletrônica` (8.56%) |
| `CD_CNAE_DOADOR` | `String` | 0.0% | 53.51% | 35 | `17338` | `96092` | `-1` (53.51%); `94928` (46.16%); `74901` (0.11%) |
| `DS_CNAE_DOADOR` | `String` | 0.0% | 53.51% | 35 | `Administração pública em geral` | `Tratamento de dados, provedores de serviços d...` | `#NULO` (53.51%); `Atividades de organizações políticas` (46.16%); `Atividades profissionais, científicas e técni...` (0.11%) |
| `NR_CPF_CNPJ_DOADOR` | `String` | 0.0% | 4.45% | 247,931 | `00000000000` | `99998602149` | `-1` (4.45%); `16847535000132` (1.21%); `08517423000195` (1.2%) |
| `NM_DOADOR` | `String` | 0.0% | 4.45% | 246,112 | `,ARLY GOMES CALDAS` | `Úrsula Costa` | `Direção Municipal/Comissão Provisória` (7.75%); `Direção Nacional` (4.67%); `#NULO` (4.45%) |
| `NM_DOADOR_RFB` | `String` | 0.0% | 4.45% | 241,935 | `10 - REPUBLICANOS - ITAPETININGA - SP - MUNIC...` | `ZYON FERNANDO DA CRUZ` | `#NULO` (4.45%); `PARTIDO DOS TRABALHADORES PT` (1.21%); `PARTIDO LIBERAL (PL)` (1.2%) |
| `CD_ESFERA_PARTIDARIA_DOADOR` | `String` | 0.0% | 85.19% | 5 | `F` | `Z` | `-1` (85.19%); `M` (7.76%); `N` (4.67%) |
| `DS_ESFERA_PARTIDARIA_DOADOR` | `String` | 0.0% | 85.19% | 5 | `Federal (Estadual/Distrital)` | `Zonal` | `#NULO` (85.19%); `Municipal` (7.76%); `Nacional` (4.67%) |
| `SG_UF_DOADOR` | `String` | 0.0% | 40.96% | 12 | `BA` | `SP` | `#NULO#` (40.96%); `MG` (31.98%); `SP` (22.38%) |
| `CD_MUNICIPIO_DOADOR` | `String` | 0.0% | 48.02% | 1,505 | `40002` | `97012` | `-1` (48.02%); `71072` (0.59%); `41238` (0.53%) |
| `NM_MUNICIPIO_DOADOR` | `String` | 0.0% | 48.02% | 1,499 | `ABADIA DOS DOURADOS` | `ÓLEO` | `#NULO` (48.02%); `SÃO PAULO` (0.59%); `BELO HORIZONTE` (0.53%) |
| `SQ_CANDIDATO_DOADOR` | `String` | 0.0% | 56.81% | 47,740 | `130001880136` | `250002554763` | `-1` (56.81%); `130001882197` (0.27%); `250001997217` (0.27%) |
| `NR_CANDIDATO_DOADOR` | `String` | 0.0% | 55.77% | 4,702 | `10` | `80` | `-1` (55.77%); `55` (6.47%); `10` (3.93%) |
| `CD_CARGO_CANDIDATO_DOADOR` | `String` | 0.0% | 55.77% | 4 | `11` | `13` | `-1` (55.77%); `11` (30.86%); `13` (12.19%) |
| `DS_CARGO_CANDIDATO_DOADOR` | `String` | 0.0% | 55.77% | 4 | `Prefeito` | `Vice-prefeito` | `#NULO` (55.77%); `Prefeito` (30.86%); `Vereador` (12.19%) |
| `NR_PARTIDO_DOADOR` | `String` | 0.0% | 40.99% | 30 | `10` | `80` | `-1` (40.99%); `55` (8.67%); `10` (5.95%) |
| `SG_PARTIDO_DOADOR` | `String` | 0.0% | 40.99% | 30 | `AGIR` | `UP` | `#NULO` (40.99%); `PSD` (8.67%); `REPUBLICANOS` (5.95%) |
| `NM_PARTIDO_DOADOR` | `String` | 0.0% | 40.99% | 42 | `AGIR` | `União Brasil` | `#NULO` (40.99%); `Partido Social Democrático` (8.66%); `REPUBLICANOS` (5.95%) |
| `NR_RECIBO_DOACAO` | `String` | 0.0% | 21.11% | 540,462 | `000101140053MG000001E` | `808001371072SP000002E` | `#NULO#` (21.11%); `000111165951SP000002E` (0.02%); `000111165951SP000001E` (0.02%) |
| `NR_DOCUMENTO_DOACAO` | `String` | 0.0% | 52.86% | 224,131 | `00059218240625` | `sn` | `#NULO#` (52.86%); `1` (1.23%); `SN` (1.18%) |
| `SQ_RECEITA` | `String` | 0.0% | 4.13% | 647,234 | `33005978` | `48779922` | `-1` (4.13%); `45234476` (0.02%); `45234477` (0.02%) |
| `DT_RECEITA` | `String` | 4.13% | 0.0% | 337 | `01/01/2024` | `31/12/2024` | `09/09/2024` (5.65%); `04/10/2024` (4.19%); `<NULL>` (4.13%) |
| `DS_RECEITA` | `String` | 0.0% | 51.72% | 74,638 | `(1000) BOTONS ELEIÇÃO 2024 ALENCAR SOARES SOB...` | `ÍMPRÊSSÃO EM PAPEL AP 75GRS (COLINHA) NO FORM...` | `#NULO` (51.72%); `SANTINHOS` (1.61%); `SANTINHO` (0.54%) |
| `VR_RECEITA` | `String` | 0.0% | 0.0% | 23,966 | `0,00` | `9999,99` | `100,00` (4.33%); `0,00` (4.13%); `1000,00` (3.72%) |
| `DS_NATUREZA_RECURSO_ESTIMAVEL` | `String` | 0.0% | 51.73% | 39 | `Alimentação` | `Água` | `#NULO` (51.73%); `Publicidade por materiais impressos` (19.69%); `Publicidade por adesivos` (9.72%) |
| `DS_GENERO` | `String` | 0.0% | 0.0% | 2 | `Feminino` | `Masculino` | `Masculino` (74.57%); `Feminino` (25.43%) |
| `DS_COR_RACA` | `String` | 0.0% | 0.0% | 6 | `Amarela` | `Sem Informação` | `Branca` (63.15%); `Parda` (26.17%); `Preta` (9.58%) |

### 📦 `tse/votacao` (254,878 linhas × 50 colunas | 5.29 MB)

| Coluna | Tipo | Nulos (%) | Sentinelas (%) | Distintos | Mínimo | Máximo | Top 3 Valores |
| :--- | :--- | ---: | ---: | ---: | :--- | :--- | :--- |
| `DT_GERACAO` | `String` | 0.0% | 0.0% | 1 | `13/11/2026` | `13/11/2026` | `13/11/2026` (100.0%) |
| `HH_GERACAO` | `String` | 0.0% | 0.0% | 1 | `02:17:14` | `02:17:14` | `02:17:14` (100.0%) |
| `ANO_ELEICAO` | `String` | 0.0% | 0.0% | 1 | `2024` | `2024` | `2024` (100.0%) |
| `CD_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `2` (99.98%); `1` (0.02%) |
| `NM_TIPO_ELEICAO` | `String` | 0.0% | 0.0% | 2 | `Eleição Extraordinária` | `Eleição Ordinária` | `Eleição Ordinária` (99.98%); `Eleição Extraordinária` (0.02%) |
| `NR_TURNO` | `String` | 0.0% | 0.0% | 2 | `1` | `2` | `1` (99.9%); `2` (0.1%) |
| `CD_ELEICAO` | `String` | 0.0% | 0.0% | 21 | `6041` | `6284` | `619` (99.88%); `620` (0.1%); `6161` (0.0%) |
| `DS_ELEICAO` | `String` | 0.0% | 0.0% | 20 | `ELEIÇÃO SUPL. SÃO JOSÉ DA VARGINHA` | `SUPLEMENTAR DE NARANDIBA - OUT/26` | `ELEIÇÕES MUNICIPAIS 2024` (99.98%); `ELEIÇÃO SUPLEMENTAR DE BOCAINA` (0.0%); `ELEIÇÃO SUPL. SÃO JOSÉ DA VARGINHA` (0.0%) |
| `DT_ELEICAO` | `String` | 0.0% | 0.0% | 11 | `03/08/2025` | `27/10/2024` | `06/10/2024` (99.88%); `27/10/2024` (0.1%); `21/06/2026` (0.0%) |
| `TP_ABRANGENCIA` | `String` | 0.0% | 0.0% | 1 | `M` | `M` | `M` (100.0%) |
| `SG_UF` | `String` | 0.0% | 0.0% | 2 | `MG` | `SP` | `SP` (63.2%); `MG` (36.8%) |
| `SG_UE` | `String` | 0.0% | 0.0% | 1,498 | `40002` | `72737` | `71072` (22.16%); `41238` (6.05%); `64777` (1.73%) |
| `NM_UE` | `String` | 0.0% | 0.0% | 1,493 | `ABADIA DOS DOURADOS` | `ÓLEO` | `SÃO PAULO` (22.16%); `BELO HORIZONTE` (6.05%); `GUARULHOS` (1.73%) |
| `CD_MUNICIPIO` | `String` | 0.0% | 0.0% | 1,498 | `40002` | `72737` | `71072` (22.16%); `41238` (6.05%); `64777` (1.73%) |
| `NM_MUNICIPIO` | `String` | 0.0% | 0.0% | 1,493 | `ABADIA DOS DOURADOS` | `ÓLEO` | `SÃO PAULO` (22.16%); `BELO HORIZONTE` (6.05%); `GUARULHOS` (1.73%) |
| `NR_ZONA` | `String` | 0.0% | 0.0% | 417 | `1` | `99` | `326` (0.58%); `328` (0.58%); `33` (0.58%) |
| `CD_CARGO` | `String` | 0.0% | 0.0% | 2 | `11` | `13` | `13` (97.69%); `11` (2.31%) |
| `DS_CARGO` | `String` | 0.0% | 0.0% | 2 | `Prefeito` | `Vereador` | `Vereador` (97.69%); `Prefeito` (2.31%) |
| `SQ_CANDIDATO` | `String` | 0.0% | 0.0% | 142,533 | `130001880122` | `250002554763` | `250001926547` (0.04%); `250002098117` (0.04%); `250002052113` (0.02%) |
| `NR_CANDIDATO` | `String` | 0.0% | 0.0% | 10,896 | `10` | `80800` | `55555` (0.48%); `55123` (0.47%); `22222` (0.44%) |
| `NM_CANDIDATO` | `String` | 0.0% | 0.0% | 138,244 | `ANANIAS TAVARES DE SOUZA` | `ÓLIVER ALONSO DELLA MATTA SILVA` | `RICARDO LUIS REIS NUNES` (0.04%); `GUILHERME CASTRO BOULOS` (0.04%); `MARIA APARECIDA DA SILVA` (0.03%) |
| `NM_URNA_CANDIDATO` | `String` | 0.0% | 0.0% | 123,351 | `JC  CESAR DE RITA DE BEG` | `Ú FONSECA` | `RICARDO NUNES` (0.05%); `GUILHERME BOULOS` (0.04%); `CESINHA` (0.03%) |
| `NM_SOCIAL_CANDIDATO` | `String` | 0.0% | 99.85% | 121 | `AGATHA BEATRIZ FELIX DE SOUZA` | `ZYDARA LOPEZ` | `#NULO` (99.85%); `JAQUELINE` (0.02%); `LEO ÁQUILA` (0.02%) |
| `CD_SITUACAO_CANDIDATURA` | `String` | 0.0% | 100.0% | 1 | `—` | `—` | `-3` (100.0%) |
| `DS_SITUACAO_CANDIDATURA` | `String` | 0.0% | 0.0% | 1 | `#NE` | `#NE` | `#NE` (100.0%) |
| `CD_DETALHE_SITUACAO_CAND` | `String` | 0.0% | 100.0% | 1 | `—` | `—` | `-3` (100.0%) |
| `DS_DETALHE_SITUACAO_CAND` | `String` | 0.0% | 0.0% | 1 | `#NE` | `#NE` | `#NE` (100.0%) |
| `CD_SITUACAO_JULGAMENTO` | `String` | 0.0% | 0.0% | 7 | `13` | `5` | `2` (98.95%); `14` (0.96%); `4` (0.04%) |
| `DS_SITUACAO_JULGAMENTO` | `String` | 0.0% | 0.0% | 7 | `CANCELADO` | `PENDENTE DE JULGAMENTO` | `DEFERIDO` (98.95%); `INDEFERIDO` (0.96%); `INDEFERIDO EM PRAZO RECURSAL OU COM RECURSO` (0.04%) |
| `CD_SITUACAO_CASSACAO` | `String` | 0.0% | 99.44% | 4 | `1` | `3` | `-1` (99.44%); `1` (0.54%); `2` (0.01%) |
| `DS_SITUACAO_CASSACAO` | `String` | 0.0% | 99.44% | 4 | `CASSADO` | `REGULAR` | `#NULO` (99.44%); `CASSADO` (0.54%); `CASSADO COM RECURSO` (0.01%) |
| `CD_SITUACAO_DCONST_DIPLOMA` | `String` | 0.0% | 99.99% | 3 | `1` | `3` | `-1` (99.99%); `3` (0.0%); `1` (0.0%) |
| `DS_SITUACAO_DCONST_DIPLOMA` | `String` | 0.0% | 99.99% | 3 | `CANCELADO` | `REGULAR` | `#NULO` (99.99%); `REGULAR` (0.0%); `CANCELADO` (0.0%) |
| `TP_AGREMIACAO` | `String` | 0.0% | 0.0% | 3 | `COLIGAÇÃO` | `PARTIDO ISOLADO` | `PARTIDO ISOLADO` (83.42%); `FEDERAÇÃO` (14.97%); `COLIGAÇÃO` (1.61%) |
| `NR_PARTIDO` | `String` | 0.0% | 0.0% | 29 | `10` | `80` | `22` (7.02%); `15` (6.95%); `55` (6.77%) |
| `SG_PARTIDO` | `String` | 0.0% | 0.0% | 29 | `AGIR` | `UP` | `PL` (7.02%); `MDB` (6.95%); `PSD` (6.77%) |
| `NM_PARTIDO` | `String` | 0.0% | 0.0% | 41 | `AGIR` | `União Brasil` | `Partido Liberal` (7.01%); `Movimento Democrático Brasileiro` (6.95%); `Partido Social Democrático` (6.76%) |
| `NR_FEDERACAO` | `String` | 0.0% | 84.76% | 6 | `100` | `104` | `-1` (84.76%); `101` (6.18%); `100` (5.7%) |
| `NM_FEDERACAO` | `String` | 0.0% | 84.76% | 8 | `FEDERAÇÃO BRASIL DA ESPERANÇA - FE BRASIL` | `Federação PSOL REDE` | `#NULO` (84.76%); `Federação BRASIL DA ESPERANÇA - FE BRASIL` (6.18%); `Federação PSDB CIDADANIA` (5.7%) |
| `SG_FEDERACAO` | `String` | 0.0% | 84.76% | 7 | `25-PRD/77-SOLIDARIEDADE` | `PT/PC do B/PV` | `#NULO` (84.76%); `PT/PC do B/PV` (6.18%); `PSDB/CIDADANIA` (5.7%) |
| `DS_COMPOSICAO_FEDERACAO` | `String` | 0.0% | 84.76% | 7 | `CIDADANIA / PSDB` | `PSOL / REDE` | `#NULO` (84.76%); `PC do B / PT / PV` (6.18%); `CIDADANIA / PSDB` (5.7%) |
| `SQ_COLIGACAO` | `String` | 0.0% | 0.0% | 17,182 | `130001687199` | `250001801987` | `250001703329` (1.25%); `250001734269` (1.25%); `250001730716` (1.25%) |
| `NM_COLIGACAO` | `String` | 0.0% | 0.0% | 2,998 | `A VERDADEIRA RENOVAÇÃO DE PANORAMA` | `É TEMPO DE MUDANÇA. SÃO JOSÉ DO BARREIRO PODE...` | `PARTIDO ISOLADO` (83.42%); `FEDERAÇÃO` (14.97%); `AMOR POR SÃO PAULO` (0.04%) |
| `DS_COMPOSICAO_COLIGACAO` | `String` | 0.0% | 0.0% | 2,248 | `AGIR` | `UP` | `PL` (6.83%); `MDB` (6.76%); `REPUBLICANOS` (6.58%) |
| `ST_VOTO_EM_TRANSITO` | `String` | 0.0% | 0.0% | 1 | `N` | `N` | `N` (100.0%) |
| `QT_VOTOS_NOMINAIS` | `String` | 0.0% | 0.0% | 5,476 | `0` | `999` | `0` (5.53%); `1` (3.84%); `2` (3.06%) |
| `NM_TIPO_DESTINACAO_VOTOS` | `String` | 0.0% | 0.0% | 4 | `Anulado` | `Válido (legenda)` | `Válido` (98.45%); `Anulado` (1.5%); `Anulado sub judice` (0.04%) |
| `QT_VOTOS_NOMINAIS_VALIDOS` | `String` | 0.0% | 0.0% | 5,430 | `0` | `999` | `0` (6.87%); `1` (3.73%); `2` (2.99%) |
| `CD_SIT_TOT_TURNO` | `String` | 0.0% | 0.0% | 6 | `1` | `6` | `5` (55.21%); `4` (35.5%); `2` (5.64%) |
| `DS_SIT_TOT_TURNO` | `String` | 0.0% | 0.0% | 6 | `2º TURNO` | `SUPLENTE` | `SUPLENTE` (55.21%); `NÃO ELEITO` (35.5%); `ELEITO POR QP` (5.64%) |
