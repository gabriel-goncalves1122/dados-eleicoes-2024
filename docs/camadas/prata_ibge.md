# 🌍 Contexto IBGE & De-Para — Camada Silver (`02_silver`)

Documentação técnica da camada Silver para os dados socioeconômicos do **IBGE** e a tabela ponte **TSE ↔ IBGE**, processados pelo script [`03_limpeza_ibge.R`](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/02_silver/scripts/03_limpeza_ibge.R).

---

## 1. Regras de Transformação Bronze → Silver

1. **Consolidação em Tabela Única (`ibge_indicadores.parquet`):** As 9 tabelas brutas da Bronze (`01_bronze/data/ibge/`) são transformadas de formato longo/múltiplo para um único dataset largo com **1 linha por município** (`5.570` municípios do Brasil).
2. **Conversão de Valores e Sentinelas (`to_num`):**
   - Strings de supressão do SIDRA (`"..."`, `"X"`) tornam-se `NA_real_`.
   - Em indicadores de ausência/proporção onde `"-"` representa zero absoluto (`zero_se_hifen = TRUE`), o hífen é convertido para `0.0`.
3. **Normalização Monetária do PIB:** Valores originalmente em **R$ mil** na Bronze são multiplicados por `1000` para ficarem em **Reais (R$)** (`pib_reais_2023`, `vab_adm_publica_reais_2021`, `vab_total_reais_2021`).
4. **Cálculo de Indicadores Derivados:**
   - `pib_per_capita_reais`: `pib_reais_2023 / populacao_2022`.
   - `pct_adm_publica_vab_2021` e `pct_impostos_pib_2021`: proporções calculadas sobre o VAB total e PIB.
   - `pct_negros_indigenas_censo`: soma de `Preta + Parda + Indígena` dividida pela categoria `Total` (`* 100`).
   - `pct_mulheres_censo`: `Mulheres / (Homens + Mulheres) * 100`.
5. **Padronização da Tabela De-Para (`depara_tse_ibge.parquet`):** Mantém apenas **MG e SP** (`1.498` municípios), com `cd_municipio_tse` (5 dígitos), `cd_municipio_ibge` (7 dígitos), `cd_municipio_ibge_6` (6 dígitos) e flag booleana `is_capital`.

---

## 2. Catálogo de Dados (`02_silver/data/`)

### 2.1 `ibge/ibge_indicadores.parquet` (`5.570` linhas | `15` colunas)
**Propósito:** Base única municipal com indicadores demográficos (Censo 2022), econômicos (PIB) e de saneamento/infraestrutura.

| Coluna | Tipo | Propósito e Origem |
| :--- | :--- | :--- |
| `cd_municipio_ibge` | `string` | **Chave primária** oficial do município no IBGE (7 dígitos). |
| `nm_municipio_ibge` | `string` | Nome do município com UF (ex: `"Saquarema - RJ"`). |
| `populacao_2022` | `int64` | População residente total (Censo 2022). |
| `pib_reais_2023` | `double` | PIB municipal a preços correntes em **Reais (R$)** (ano-base 2023). |
| `pib_per_capita_reais` | `double` | PIB *per capita* em Reais (`pib_reais_2023 / populacao_2022`). |
| `vab_adm_publica_reais_2021` | `double` | Valor Adicionado Bruto da Administração Pública em Reais. |
| `pct_adm_publica_vab_2021` | `double` | Participação percentual da Administração Pública no VAB total. |
| `pct_impostos_pib_2021` | `double` | Participação percentual de impostos líquidos de subsídios no PIB. |
| `taxa_alfabetizacao_15mais` | `double` | Taxa de alfabetização da população com 15 anos ou mais (%). |
| `pct_populacao_urbana` | `double` | Percentual da população residente em área urbana (%). |
| `pct_agua_rede_geral` | `double` | Percentual de domicílios atendidos por rede geral de água (%). |
| `pct_esgoto_adequado` | `double` | Percentual de domicílios com rede geral, pluvial ou fossa ligada à rede (%). |
| `pct_sem_banheiro` | `double` | Percentual de domicílios sem banheiro nem sanitário (%). |
| `pct_mulheres_censo` | `double` | Percentual de mulheres na população total (%). |
| `pct_negros_indigenas_censo` | `double` | Percentual de população preta, parda ou indígena (%). |

---

### 2.2 `depara_tse_ibge.parquet` (`1.498` linhas | `6` colunas)
**Propósito:** Tabela ponte higienizada para cruzar as bases do TSE (`cd_municipio_tse`) com `ibge_indicadores.parquet` (`cd_municipio_ibge`) em MG e SP.

| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `cd_municipio_tse` | `string` | Código TSE do município (5 dígitos, ex: `"40010"`). |
| `cd_municipio_ibge` | `string` | Código IBGE do município (7 dígitos, ex: `"3100104"`). |
| `cd_municipio_ibge_6` | `string` | Código IBGE sem dígito verificador (6 dígitos). |
| `sg_uf` | `string` | Sigla da UF (`"MG"` ou `"SP"`). |
| `nm_municipio_tse` | `string` | Nome do município no TSE em caixa alta. |
| `is_capital` | `bool` | Indicador booleano (`TRUE` para Belo Horizonte e São Paulo). |
