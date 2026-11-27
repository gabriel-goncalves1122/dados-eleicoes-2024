# 🏛️ Contexto TSE — Camada Bronze (`01_bronze`)

Documentação técnica completa da ingestão, especificação da API/CDN, catálogo de dados (colunas, tipos e propósitos) e particularidades das bases eleitorais do **Tribunal Superior Eleitoral (TSE)** para as **Eleições Municipais de 2024 (MG e SP)**.

---

## 1. Especificação da API / CDN de Extração (`01_bronze/scripts/01_ingestao_tse.R`)

- **Fonte Oficial:** Repositório de Dados Eleitorais (ODSELE) — Portal de Dados Abertos do TSE.
- **Host Base:** `https://cdn.tse.jus.br/estatistica/sead/odsele/`
- **Autenticação:** Pública (acesso direto via HTTP/HTTPS sem token).
- **Método de Transferência:** `download.file(..., method = "curl", mode = "wb")` com conversão em streaming para Apache Parquet (`compression = "zstd"`) e descarte imediato dos `.zip` e `.csv` temporários.

### Endpoints e Regras de Extração
| Dataset Bronze | Endpoint no CDN TSE (`.../odsele/`) | Filtro Regex Aplicado no ZIP |
| :--- | :--- | :--- |
| `candidatos.parquet` | `consulta_cand/consulta_cand_2024.zip` | `consulta_cand_2024_(MG\|SP)\.csv$` |
| `bens.parquet` | `bem_candidato/bem_candidato_2024.zip` | `bem_candidato_2024_(MG\|SP)\.csv$` |
| `votacao.parquet` | `votacao_candidato_munzona/votacao_candidato_munzona_2024.zip` | `votacao_candidato_munzona_2024_(MG\|SP)\.csv$` |
| `receitas.parquet` | `prestacao_contas/prestacao_de_contas_eleitorais_candidatos_2024.zip` | `receitas_candidatos_2024_(MG\|SP)\.csv$` |
| `despesas.parquet` | `prestacao_contas/prestacao_de_contas_eleitorais_candidatos_2024.zip` | `despesas_contratadas_candidatos_2024_(MG\|SP)\.csv$` |

### Parâmetros e Regras Operacionais
- **`UFS_ALVO`:** `c("MG", "SP")`. Apenas os CSVs estaduais correspondentes são extraídos de dentro dos arquivos `.zip` nacionais.
- **`options(timeout = 1800)`:** Tempo limite ampliado para 30 minutos para suportar o download do pacote de prestação de contas (>1 GB compactado).
- **Formato de Origem:** CSV delimitado por ponto e vírgula (`;`), lido via `arrow::open_dataset(..., format = "csv", delimiter = ";")`.
- **Política de Tipagem Bronze:** Todas as colunas são mantidas como `string` (UTF-8) para evitar perda de zeros à esquerda em chaves (`SQ_CANDIDATO`, `SG_UE`, `NR_CPF_CNPJ_*`) e erros de parsing em decimais brasileiros com vírgula.

---

## 2. Particularidades Críticas dos Dados do TSE

1. **Eleições Ordinárias vs. Suplementares:** As bases `candidatos.parquet` e `votacao.parquet` contêm registros de `CD_TIPO_ELEICAO = "2"` (`ELEIÇÃO ORDINÁRIA`, 06/10/2024) **e** `CD_TIPO_ELEICAO = "1"` (`ELEIÇÃO SUPLEMENTAR`, ex: *Eleição Suplementar Buritis*). A camada Silver deve filtrar `CD_TIPO_ELEICAO == "2"` caso o objetivo seja analisar apenas o pleito geral municipal de 2024.
2. **Chave Municipal (`SG_UE` vs `CD_MUNICIPIO`):** Em `candidatos`, `bens`, `receitas` e `despesas`, **não existe** a coluna `CD_MUNICIPIO` — o código TSE do município (5 dígitos) vem armazenado em `SG_UE`. Apenas `votacao.parquet` possui ambas (`SG_UE` e `CD_MUNICIPIO`).
3. **Valores Monetários com Vírgula:** Campos como `VR_BEM_CANDIDATO`, `VR_RECEITA` e `VR_DESPESA_CONTRATADA` estão em formato texto brasileiro (ex: `"1500,75"`). Exigem `str_replace_all(..., ",", ".")` antes do cast para `numeric`/`double`.
4. **Valores Sentinela:** Campos ausentes, sigilosos ou não aplicáveis são preenchidos pelo TSE com `"#NULO"`, `"#NE"`, `"-1"`, `"-3"` ou `"NÃO DIVULGÁVEL"`.
5. **Granularidade de Turnos:** `votacao.parquet` separa votos de 1º e 2º turno pela coluna `NR_TURNO` (`"1"` e `"2"`). Já `receitas.parquet` e `despesas.parquet` consolidam a prestação financeira da campanha (podendo ter entregas `Parcial` e `Final` em `TP_PRESTACAO_CONTAS`).

---

## 3. Catálogo de Dados Detalhado (`01_bronze/data/tse/`)

### 3.1 `candidatos.parquet` (`151.948` linhas | `50` colunas)
**Propósito:** Cadastro completo de candidaturas registradas para `PREFEITO`, `VICE-PREFEITO` e `VEREADOR` em MG e SP.

| Grupo / Colunas | Tipo | Propósito e Valores Observados |
| :--- | :--- | :--- |
| `DT_GERACAO`, `HH_GERACAO` | `string` | Data (`DD/MM/AAAA`) e hora da geração do arquivo pelo TSE. |
| `ANO_ELEICAO`, `CD_TIPO_ELEICAO`, `NM_TIPO_ELEICAO`, `NR_TURNO`, `CD_ELEICAO`, `DS_ELEICAO`, `DT_ELEICAO`, `TP_ABRANGENCIA` | `string` | Identificação do pleito (`"2024"`, `"1"`/`"2"`, `"MUNICIPAL"`). |
| `SG_UF`, `SG_UE`, `NM_UE` | `string` | UF (`"MG"`, `"SP"`), código TSE do município (5 dígitos) e nome do município. |
| `CD_CARGO`, `DS_CARGO` | `string` | Cargo disputado: `"PREFEITO"`, `"VICE-PREFEITO"`, `"VEREADOR"`. |
| `SQ_CANDIDATO` | `string` | **Chave primária** única do candidato na eleição. |
| `NR_CANDIDATO`, `NM_CANDIDATO`, `NM_URNA_CANDIDATO`, `NM_SOCIAL_CANDIDATO` | `string` | Número na urna, nome civil, nome de urna e nome social. |
| `NR_CPF_CANDIDATO`, `NR_TITULO_ELEITORAL_CANDIDATO`, `DS_EMAIL` | `string` | Identificação civil/eleitoral e e-mail de campanha. |
| `CD_SITUACAO_CANDIDATURA`, `DS_SITUACAO_CANDIDATURA` | `string` | Situação do registro (Apto, Inapto, Deferido, Indeferido). |
| `TP_AGREMIACAO`, `NR_PARTIDO`, `SG_PARTIDO`, `NM_PARTIDO` | `string` | Tipo de agremiação e identificação partidária. |
| `NR_FEDERACAO`, `NM_FEDERACAO`, `SG_FEDERACAO`, `DS_COMPOSICAO_FEDERACAO` | `string` | Metadados de federação partidária (quando aplicável). |
| `SQ_COLIGACAO`, `NM_COLIGACAO`, `DS_COMPOSICAO_COLIGACAO` | `string` | Identificador e composição da coligação majoritária. |
| `SG_UF_NASCIMENTO`, `DT_NASCIMENTO` | `string` | Naturalidade (UF) e data de nascimento (`DD/MM/AAAA`). |
| `CD_GENERO`, `DS_GENERO`, `CD_COR_RACA`, `DS_COR_RACA` | `string` | Gênero e cor/raça autodeclarados. |
| `CD_GRAU_INSTRUCAO`, `DS_GRAU_INSTRUCAO`, `CD_ESTADO_CIVIL`, `DS_ESTADO_CIVIL`, `CD_OCUPACAO`, `DS_OCUPACAO` | `string` | Escolaridade, estado civil e ocupação principal declarada. |
| `CD_SIT_TOT_TURNO`, `DS_SIT_TOT_TURNO` | `string` | Resultado no turno: `"ELEITO"`, `"ELEITO POR QP"`, `"ELEITO POR MÉDIA"`, `"2º TURNO"`, `"SUPLENTE"`, `"NÃO ELEITO"`, `"#NULO"`. |

---

### 3.2 `votacao.parquet` (`254.878` linhas | `50` colunas)
**Propósito:** Totalização de votos nominais por candidato, município, zona eleitoral e turno.

| Grupo / Colunas | Tipo | Propósito |
| :--- | :--- | :--- |
| `DT_GERACAO`, `HH_GERACAO`, `ANO_ELEICAO`, `CD_TIPO_ELEICAO`, `NM_TIPO_ELEICAO`, `NR_TURNO`, `CD_ELEICAO`, `DS_ELEICAO`, `DT_ELEICAO`, `TP_ABRANGENCIA` | `string` | Metadados da eleição e indicador de turno (`"1"` ou `"2"`). |
| `SG_UF`, `SG_UE`, `NM_UE`, `CD_MUNICIPIO`, `NM_MUNICIPIO`, `NR_ZONA` | `string` | Localização geográfica (código TSE 5 dígitos) e número da zona eleitoral. |
| `CD_CARGO`, `DS_CARGO`, `SQ_CANDIDATO`, `NR_CANDIDATO`, `NM_CANDIDATO`, `NM_URNA_CANDIDATO`, `NM_SOCIAL_CANDIDATO` | `string` | Identificação do candidato (`SQ_CANDIDATO` conecta com `candidatos.parquet`). |
| `CD_SITUACAO_CANDIDATURA`, `DS_SITUACAO_CANDIDATURA`, `CD_DETALHE_SITUACAO_CAND`, `DS_DETALHE_SITUACAO_CAND` | `string` | Situação jurídica da candidatura no momento da totalização. |
| `CD_SITUACAO_JULGAMENTO`, `DS_SITUACAO_JULGAMENTO`, `CD_SITUACAO_CASSACAO`, `DS_SITUACAO_CASSACAO`, `CD_SITUACAO_DCONST_DIPLOMA`, `DS_SITUACAO_DCONST_DIPLOMA` | `string` | Indicadores de processos judiciais, cassação ou desconstituição de diploma. |
| `TP_AGREMIACAO`, `NR_PARTIDO`, `SG_PARTIDO`, `NM_PARTIDO`, `NR_FEDERACAO`, `NM_FEDERACAO`, `SG_FEDERACAO`, `DS_COMPOSICAO_FEDERACAO`, `SQ_COLIGACAO`, `NM_COLIGACAO`, `DS_COMPOSICAO_COLIGACAO` | `string` | Estrutura partidária, federação e coligação. |
| `ST_VOTO_EM_TRANSITO` | `string` | Flag de voto em trânsito. |
| `QT_VOTOS_NOMINAIS`, `NM_TIPO_DESTINACAO_VOTOS`, `QT_VOTOS_NOMINAIS_VALIDOS` | `string` | Votos nominais brutos, destinação (`Válido` vs `Anulado sub judice`) e votos válidos computados. |
| `CD_SIT_TOT_TURNO`, `DS_SIT_TOT_TURNO` | `string` | Situação final de totalização no turno. |

---

### 3.3 `bens.parquet` (`310.847` linhas | `19` colunas)
**Propósito:** Declaração patrimonial detalhada por candidato (imóveis, veículos, participações societárias, aplicações). *Atenção: candidatos sem bens declarados não constam neste arquivo.*

| Coluna(s) | Tipo | Propósito |
| :--- | :--- | :--- |
| `DT_GERACAO`, `HH_GERACAO`, `ANO_ELEICAO`, `CD_TIPO_ELEICAO`, `NM_TIPO_ELEICAO`, `CD_ELEICAO`, `DS_ELEICAO`, `DT_ELEICAO` | `string` | Metadados de geração e eleição. |
| `SG_UF`, `SG_UE`, `NM_UE` | `string` | UF e município da candidatura. |
| `SQ_CANDIDATO` | `string` | Chave estrangeira para `candidatos.parquet`. |
| `NR_ORDEM_BEM_CANDIDATO` | `string` | Ordem sequencial do item na declaração do candidato. |
| `CD_TIPO_BEM_CANDIDATO`, `DS_TIPO_BEM_CANDIDATO` | `string` | Código e categoria padronizada do bem. |
| `DS_BEM_CANDIDATO` | `string` | Descrição textual livre informada pelo candidato. |
| `VR_BEM_CANDIDATO` | `string` | Valor monetário do bem em reais (separador decimal `,`). |
| `DT_ULT_ATUAL_BEM_CANDIDATO`, `HH_ULT_ATUAL_BEM_CANDIDATO` | `string` | Data e hora da última atualização do registro patrimonial. |

---

### 3.4 `receitas.parquet` (`713.921` linhas | `60` colunas)
**Propósito:** Lançamentos de receitas de campanha (doações financeiras, estimáveis, recursos próprios e repasses de fundos públicos).

| Grupo / Colunas | Tipo | Propósito e Valores Observados |
| :--- | :--- | :--- |
| `DT_GERACAO`, `HH_GERACAO`, `AA_ELEICAO`, `CD_TIPO_ELEICAO`, `NM_TIPO_ELEICAO`, `CD_ELEICAO`, `DS_ELEICAO`, `DT_ELEICAO`, `ST_TURNO` | `string` | Metadados da eleição e turno. |
| `TP_PRESTACAO_CONTAS`, `DT_PRESTACAO_CONTAS`, `SQ_PRESTADOR_CONTAS`, `NR_CNPJ_PRESTADOR_CONTA` | `string` | Tipo da prestação, data de entrega e CNPJ exclusivo da campanha. |
| `SG_UF`, `SG_UE`, `NM_UE`, `CD_CARGO`, `DS_CARGO`, `SQ_CANDIDATO`, `NR_CANDIDATO`, `NM_CANDIDATO`, `NR_CPF_CANDIDATO`, `NR_CPF_VICE_CANDIDATO`, `NR_PARTIDO`, `SG_PARTIDO`, `NM_PARTIDO` | `string` | Identificação do candidato recebedor (`SQ_CANDIDATO`). |
| `CD_FONTE_RECEITA`, `DS_FONTE_RECEITA` | `string` | Fonte do recurso: `"FUNDO ESPECIAL"`, `"FUNDO PARTIDARIO"`, `"OUTROS RECURSOS"`, `"#NULO"`. |
| `CD_ORIGEM_RECEITA`, `DS_ORIGEM_RECEITA` | `string` | Origem detalhada (ex: `"Recursos de pessoas físicas"`, `"Recursos de partido político"`, `"Recursos próprios"`, `"Recursos de Financiamento Coletivo"`). |
| `CD_NATUREZA_RECEITA`, `DS_NATUREZA_RECEITA`, `CD_ESPECIE_RECEITA`, `DS_ESPECIE_RECEITA` | `string` | Natureza (Financeira/Estimável) e espécie (PIX, Transferência, Cheque, etc.). |
| `CD_CNAE_DOADOR`, `DS_CNAE_DOADOR`, `NR_CPF_CNPJ_DOADOR`, `NM_DOADOR`, `NM_DOADOR_RFB`, `CD_ESFERA_PARTIDARIA_DOADOR`, `DS_ESFERA_PARTIDARIA_DOADOR`, `SG_UF_DOADOR`, `CD_MUNICIPIO_DOADOR`, `NM_MUNICIPIO_DOADOR` | `string` | Dados cadastrais, CNAE e localização do doador originário. |
| `SQ_CANDIDATO_DOADOR`, `NR_CANDIDATO_DOADOR`, `CD_CARGO_CANDIDATO_DOADOR`, `DS_CARGO_CANDIDATO_DOADOR`, `NR_PARTIDO_DOADOR`, `SG_PARTIDO_DOADOR`, `NM_PARTIDO_DOADOR` | `string` | Identificação eleitoral quando o doador é outro candidato/partido. |
| `NR_RECIBO_DOACAO`, `NR_DOCUMENTO_DOACAO`, `SQ_RECEITA`, `DT_RECEITA`, `DS_RECEITA`, `VR_RECEITA`, `DS_NATUREZA_RECURSO_ESTIMAVEL` | `string` | Comprovante, data, descrição e valor da receita (`VR_RECEITA` com vírgula decimal). |
| `DS_GENERO`, `DS_COR_RACA` | `string` | Gênero e cor/raça do candidato beneficiário. |

---

### 3.5 `despesas.parquet` (`1.276.510` linhas | `53` colunas)
**Propósito:** Lançamentos de despesas contratadas pelos candidatos durante a campanha eleitoral.

| Grupo / Colunas | Tipo | Propósito |
| :--- | :--- | :--- |
| `DT_GERACAO`, `HH_GERACAO`, `AA_ELEICAO`, `CD_TIPO_ELEICAO`, `NM_TIPO_ELEICAO`, `CD_ELEICAO`, `DS_ELEICAO`, `DT_ELEICAO`, `ST_TURNO` | `string` | Metadados da eleição e turno. |
| `TP_PRESTACAO_CONTAS`, `DT_PRESTACAO_CONTAS`, `SQ_PRESTADOR_CONTAS`, `NR_CNPJ_PRESTADOR_CONTA` | `string` | Entrega contábil e CNPJ da campanha. |
| `SG_UF`, `SG_UE`, `NM_UE`, `CD_CARGO`, `DS_CARGO`, `SQ_CANDIDATO`, `NR_CANDIDATO`, `NM_CANDIDATO`, `NR_CPF_CANDIDATO`, `NR_CPF_VICE_CANDIDATO`, `NR_PARTIDO`, `SG_PARTIDO`, `NM_PARTIDO` | `string` | Identificação do candidato contratante. |
| `CD_TIPO_FORNECEDOR`, `DS_TIPO_FORNECEDOR`, `CD_CNAE_FORNECEDOR`, `DS_CNAE_FORNECEDOR`, `NR_CPF_CNPJ_FORNECEDOR`, `NM_FORNECEDOR`, `NM_FORNECEDOR_RFB` | `string` | Tipo (PF/PJ), CNAE econômico, CPF/CNPJ e razão social do fornecedor. |
| `CD_ESFERA_PART_FORNECEDOR`, `DS_ESFERA_PART_FORNECEDOR`, `SG_UF_FORNECEDOR`, `CD_MUNICIPIO_FORNECEDOR`, `NM_MUNICIPIO_FORNECEDOR` | `string` | Localização e esfera partidária do fornecedor. |
| `SQ_CANDIDATO_FORNECEDOR`, `NR_CANDIDATO_FORNECEDOR`, `CD_CARGO_FORNECEDOR`, `DS_CARGO_FORNECEDOR`, `NR_PARTIDO_FORNECEDOR`, `SG_PARTIDO_FORNECEDOR`, `NM_PARTIDO_FORNECEDOR` | `string` | Identificação quando o fornecedor é outro candidato/partido. |
| `DS_TIPO_DOCUMENTO`, `NR_DOCUMENTO`, `CD_ORIGEM_DESPESA`, `DS_ORIGEM_DESPESA`, `SQ_DESPESA`, `DT_DESPESA`, `DS_DESPESA`, `VR_DESPESA_CONTRATADA` | `string` | Nota fiscal/recibo, categoria da despesa, data, descrição e valor contratado. |
