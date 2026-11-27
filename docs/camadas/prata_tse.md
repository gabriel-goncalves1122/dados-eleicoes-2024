# 🏛️ Contexto TSE — Camada Silver (`02_silver`)

Documentação técnica da camada Silver para os dados eleitorais do **TSE 2024 (MG e SP)**, cobrindo as regras de transformação Bronze → Silver, tipagem forte (`snake_case`, tipos nativos `date32`, `int8/16/32`, `double`, `bool`), tratamento de sentinelas e o catálogo completo das **5 bases higienizadas**.

---

## 1. Regras de Transformação Bronze → Silver

Os scripts [`01_limpeza_tse_candidatos.R`](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/02_silver/scripts/01_limpeza_tse_candidatos.R) e [`02_limpeza_tse_financas.R`](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/02_silver/scripts/02_limpeza_tse_financas.R) aplicam as seguintes padronizações sobre os arquivos da Bronze (`01_bronze/data/tse/`):

1. **Padronização de Nomenclatura:** Todas as colunas são renomeadas para `snake_case` (ex: `SQ_CANDIDATO` → `sq_candidato`, `SG_UE` → `cd_municipio_tse`).
2. **Remoção de Sentinelas (`limpar_sentinela`):** Strings como `"#NULO#"`, `"#NULO"`, `"#NE#"`, `"#NE"`, `"-1"`, `"-3"`, `"-4"` e `""` são convertidas em `NA_character_`.
3. **Padding de Chaves:** `cd_municipio_tse` é padronizado com 5 dígitos (`str_pad(..., 5, "left", "0")`).
4. **Conversão de Tipos Nativos:**
   - Datas (`DT_NASCIMENTO`, `DT_ELEICAO`, `DT_RECEITA`, `DT_DESPESA`) convertidas de `DD/MM/AAAA` para `date32[day]`.
   - Valores monetários (`VR_RECEITA`, `VR_DESPESA_CONTRATADA`, `VR_BEM_CANDIDATO`) têm vírgula substituída por ponto e são convertidos para `double`.
   - Códigos numéricos e contagens (`cd_cargo`, `nr_partido`, `nr_turno`, `nr_zona`, `qt_votos_nominais`, `idade_2024`) convertidos para inteiros compactos (`int8`, `int16`, `int32`).
5. **Deduplicação e Filtros de Integridade:**
   - `candidatos_clean.parquet`: deduplicado por `sq_candidato` mantendo o registro do turno mais recente (`arrange(sq_candidato, desc(nr_turno), desc(dt_eleicao)) %>% distinct(sq_candidato, .keep_all = TRUE)`). Reduz de `151.948` (Bronze) para `151.868` candidatos únicos.
   - `votacao`, `receitas`, `despesas`, `bens`: filtrados para remover `sq_candidato` nulo e valores negativos (`>= 0`).

---

## 2. Catálogo de Dados (`02_silver/data/tse/`)

### 2.1 `candidatos_clean.parquet` (`151.868` linhas | `26` colunas)
**Propósito:** Cadastro único por candidato (`sq_candidato`) em MG e SP, já com idade calculada e flags de resultado eleitoral.

| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `sq_candidato` | `string` | **Chave primária** única do candidato na eleição. |
| `nr_candidato` | `string` | Número de urna do candidato. |
| `nm_candidato`, `nm_urna_candidato` | `string` | Nome civil e nome de urna normalizados (caixa alta, espaços limpos). |
| `sg_uf` | `string` | Sigla da UF (`"MG"` ou `"SP"`). |
| `cd_municipio_tse` | `string` | Código TSE do município (5 dígitos, ex: `"47791"`), originado de `SG_UE`. |
| `nm_municipio` | `string` | Nome do município em caixa alta. |
| `cd_cargo`, `ds_cargo` | `int16`, `string` | Código (`11`, `12`, `13`) e descrição (`PREFEITO`, `VICE-PREFEITO`, `VEREADOR`). |
| `nr_partido`, `sg_partido`, `nm_partido` | `int16`, `string`, `string` | Número, sigla e nome do partido. |
| `tp_agremiacao`, `sg_federacao` | `string` | Tipo de agremiação e sigla da federação (`NA` se não aplicável). |
| `ds_genero`, `ds_cor_raca`, `ds_grau_instrucao`, `ds_estado_civil`, `ds_ocupacao` | `string` | Perfil demográfico e ocupacional higienizado. |
| `dt_nascimento` | `date32[day]` | Data de nascimento. |
| `nr_turno`, `dt_eleicao` | `int8`, `date32[day]` | Turno mais recente disputado e data do pleito. |
| `ds_sit_tot_turno` | `string` | Situação bruta na totalização (sem sentinelas). |
| `idade_2024` | `int16` | Idade calculada em 2024 (`2024L - ano_nascimento`). |
| `is_eleito` | `bool` | Flag booleana (`TRUE` se `ELEITO`, `MÉDIA` ou `QUOCIENTE`). |
| `status_eleicao` | `string` | Categoria consolidada: `"Eleito"`, `"2º Turno"`, `"Suplente"` ou `"Não Eleito"`. |

---

### 2.2 `votacao_munzona_clean.parquet` (`254.878` linhas | `11` colunas)
**Propósito:** Votos nominais por candidato, zona eleitoral e turno.

| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `nr_turno`, `dt_eleicao` | `int8`, `date32[day]` | Turno (`1` ou `2`) e data da eleição. |
| `sg_uf`, `cd_municipio_tse`, `nm_municipio` | `string` | UF, código TSE do município (5 dígitos) e nome do município. |
| `nr_zona` | `int16` | Número da zona eleitoral. |
| `cd_cargo`, `ds_cargo` | `int16`, `string` | Código e descrição do cargo. |
| `sq_candidato`, `nr_candidato` | `string` | Chave estrangeira do candidato e número de urna. |
| `qt_votos_nominais` | `int32` | Quantidade de votos nominais válidos/computados (`>= 0`). |

---

### 2.3 `bens_candidatos_clean.parquet` (`100.971` linhas | `3` colunas)
**Propósito:** Tabela agregada na Silver com o patrimônio total declarado por candidato (`sq_candidato`).

| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `sq_candidato` | `string` | **Chave primária** (candidatos que declararam ao menos 1 bem). |
| `total_patrimonio_declarado` | `double` | Soma do valor de todos os bens declarados pelo candidato (em R$). |
| `qtd_bens_declarados` | `int32` | Quantidade de itens patrimoniais declarados. |

---

### 2.4 `receitas_clean.parquet` (`713.921` linhas | `12` colunas)
**Propósito:** Lançamentos financeiros de receitas de campanha higienizados.

| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `sq_candidato` | `string` | Chave estrangeira do candidato beneficiário. |
| `sg_uf`, `cd_municipio_tse` | `string` | UF e código TSE do município (5 dígitos). |
| `dt_receita` | `date32[day]` | Data do recebimento do recurso. |
| `ds_fonte_receita`, `ds_origem_receita`, `ds_natureza_receita`, `ds_especie_receita` | `string` | Classificação da fonte, origem, natureza e espécie da receita. |
| `vr_receita` | `double` | Valor da receita em reais (`>= 0`). |
| `nr_cpf_cnpj_doador`, `nm_doador` | `string` | CPF/CNPJ e nome do doador em caixa alta (sem sentinelas). |
| `is_fundo_publico` | `bool` | Flag booleana (`TRUE` quando `ds_fonte_receita` contém `FUNDO ESPECIAL` ou `FUNDO PARTID`). |

---

### 2.5 `despesas_clean.parquet` (`1.276.510` linhas | `10` colunas)
**Propósito:** Lançamentos de despesas contratadas de campanha higienizados.

| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `sq_candidato` | `string` | Chave estrangeira do candidato contratante. |
| `sg_uf`, `cd_municipio_tse` | `string` | UF e código TSE do município (5 dígitos). |
| `dt_despesa` | `date32[day]` | Data da contratação da despesa. |
| `ds_origem_despesa`, `ds_despesa`, `ds_tipo_documento` | `string` | Categoria do gasto, descrição e tipo de documento fiscal. |
| `vr_despesa_contratada` | `double` | Valor contratado em reais (`>= 0`). |
| `nr_cpf_cnpj_fornecedor`, `nm_fornecedor` | `string` | CPF/CNPJ e nome do fornecedor em caixa alta (sem sentinelas). |
