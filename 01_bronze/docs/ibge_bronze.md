# 🌍 Contexto IBGE & Tabela De-Para — Camada Bronze (`01_bronze`)

Documentação técnica completa da ingestão via **API SIDRA (IBGE)** e tabela ponte **TSE ↔ IBGE**, incluindo sintaxe de parâmetros, regras de uso, catálogo detalhado das **10 bases** e particularidades dos dados.

---

## 1. Especificação da API SIDRA (`01_bronze/scripts/02_ingestao_ibge.R`)

- **Origem:** Sistema IBGE de Recuperação Automática (SIDRA), consumido via pacote R `sidrar::get_sidra(api = "...")`.
- **Host Base:** `https://apisidra.ibge.gov.br/values`
- **Autenticação:** Pública (não requer chave de API).

### Anatomia da String de Parâmetros (`api = "..."`)
Cada chamada segue o padrão REST do SIDRA:
`/t/{tabela}/n{nivel}/{territorio}/v/{variaveis}/p/{periodo}[/c{classificacao}/{categorias}]`

| Segmento | Significado | Valores Usados no Projeto |
| :--- | :--- | :--- |
| `/t/{id}` | Tabela SIDRA | `4709` (População), `5938` (PIB), `9606` (Cor/Raça), `9543` (Alfabetização), `9923` (Urbano/Rural), `6805` (Esgoto), `6804` (Água) |
| `/n6/all` | Nível Territorial | `n6` = **Município**; `all` = todos os **5.570 municípios** do Brasil |
| `/v/{ids}` | Variáveis | `93` (População), `1000093` (% População), `37` (PIB), `513/514/525` (% VAB setorial), `526/527` (% Adm. Pública), `2513` (Taxa alfabetização), `1000381` (% Domicílios) |
| `/p/{per}` | Período | `2022` (Censo 2022) ou `last%201` (último ano consolidado do PIB: `2023`) |
| `/c{id}/{cat}` | Classificações | `c86` (Cor/raça), `c2` (Sexo), `c287` (Idade), `c1` (Situação domicílio), `c11558` (Esgotamento), `c301` (Abastecimento água) |

### Mapeamento das 9 Consultas Configuradas
| Arquivo Gerado | Tabela | Query API Exata |
| :--- | :--- | :--- |
| `populacao_2022.parquet` | `4709` | `/t/4709/n6/all/v/93/p/2022` |
| `pib_municipal.parquet` | `5938` | `/t/5938/n6/all/v/37/p/last%201` |
| `pib_composicao_setorial.parquet` | `5938` | `/t/5938/n6/all/v/37,514,525,513/p/last%201` |
| `pib_peso_administracao_publica.parquet` | `5938` | `/t/5938/n6/all/v/526,527/p/last%201` |
| `censo2022_cor_raca_sexo.parquet` | `9606` | `/t/9606/n6/all/v/93/p/2022/c86/all/c2/4,5/c287/9309` |
| `censo2022_taxa_alfabetizacao.parquet` | `9543` | `/t/9543/n6/all/v/2513/p/2022/c2/6794/c86/95251/c287/100362` |
| `censo2022_urbana_rural.parquet` | `9923` | `/t/9923/n6/all/v/93,1000093/p/2022/c1/1,2` |
| `censo2022_esgotamento_sanitario.parquet` | `6805` | `/t/6805/n6/all/v/1000381/p/2022/c11558/46290,92861` |
| `censo2022_abastecimento_agua.parquet` | `6804` | `/t/6804/n6/all/v/1000381/p/2022/c301/31471` |

### Regras e Limites da API SIDRA
1. **Teto de 50.000 células por requisição:** Consultas com `n6/all` (5.570 municípios) multiplicadas por muitas categorias podem atingir o limite da API e retornar erro HTTP 400. Caso expanda novas classificações, filtre os estados diretamente na query (ex: `/n6/in%20n3%2031,35` para MG e SP).
2. **Caracteres Especiais de Supressão:** O SIDRA retorna `"..."` (dado não disponível/suprimido por sigilo estatístico), `"-"` (zero absoluto) ou `"X"` (dado omitido para evitar desidentificação). Todas as colunas numéricas vêm como `string` na Bronze exatamente para não quebrar nessas células.

---

## 2. Especificação da Tabela De-Para (`01_bronze/scripts/03_ingestao_depara.R`)

- **Origem:** Repositório comunitário consolidado a partir dos cadastros oficiais do TSE e IBGE (`betafcc/Municipios-Brasileiros-TSE`).
- **Endpoint Direto:** `https://raw.githubusercontent.com/betafcc/Municipios-Brasileiros-TSE/master/municipios_brasileiros_tse.csv`
- **Regras de Ingestão:**
  1. Leitura forçada como texto (`cols(.default = "c")`).
  2. Padding com zeros à esquerda: `codigo_tse` (5 dígitos) e `codigo_ibge` (7 dígitos).
  3. Derivação de `codigo_ibge_6` (6 primeiros dígitos sem dígito verificador).
  4. Filtro aplicado na saída para `uf %in% c("MG", "SP")` (`1.498` municípios).

---

## 3. Particularidades Críticas dos Dados IBGE

1. **Abrangência Nacional vs. Estadual:** Diferente das bases do TSE e do De-Para (já recortadas para MG/SP), **todos os 9 arquivos do IBGE contêm os 5.570 municípios do Brasil**. O filtro para MG e SP ocorre na Silver/Gold ao cruzar com `depara_tse_ibge.parquet`.
2. **Formato de `nome_municipio`:** Sempre inclui a UF no final (ex: `"Alta Floresta D'Oeste - RO"`). Nunca faça join por nome — utilize exclusivamente `codigo_ibge` (7 dígitos).
3. **Unidade do PIB:** Os valores monetários da Tabela 5938 (`pib`, `valor_mil_reais`) estão expressos em **milhares de reais (R$ mil)** e referem-se ao ano-base `2023`.
4. **Linhas Totalizadoras em `censo2022_cor_raca_sexo.parquet`:** Como a query usa `/c86/all`, o arquivo inclui a categoria `"Total"` junto com `"Branca"`, `"Preta"`, `"Amarela"`, `"Parda"` e `"Indígena"`. Ao somar populações na Silver/Gold, **filtre `cor_raca != "Total"`** para não duplicar o total populacional.

---

## 4. Catálogo de Dados Detalhado (`01_bronze/data/ibge/` e `depara`)

### 4.1 `populacao_2022.parquet` (`5.570` linhas | `3` colunas)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge` | `string` | Chave primária oficial do município (7 dígitos). |
| `nome_municipio` | `string` | Nome do município seguido de ` - UF`. |
| `populacao` | `string` | População residente total no Censo 2022 (ex: `"21494"`). |

### 4.2 `pib_municipal.parquet` (`5.570` linhas | `4` colunas)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge` | `string` | Chave oficial do município (7 dígitos). |
| `nome_municipio` | `string` | Nome do município com UF. |
| `pib` | `string` | PIB a preços correntes em **R$ mil** (ex: `"1046343.0"`). |
| `ano_pib` | `string` | Ano de referência da série (`"2023"`). |

### 4.3 `pib_composicao_setorial.parquet` (`22.280` linhas | `6` colunas)
**Particularidade:** Formato longo (4 linhas por município). Contém `"..."` em células sem apuração.

| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge`, `nome_municipio`, `ano` | `string` | Identificação municipal e ano (`"2023"`). |
| `codigo_variavel`, `variavel` | `string` | `"37"` (PIB Total em R$ mil), `"514"` (% VAB Agropecuária), `"513"` (% VAB Indústria), `"525"` (% VAB Serviços). |
| `valor_mil_reais` | `string` | Valor da variável (R$ mil para var `37`; percentual para `513`/`514`/`525`). |

### 4.4 `pib_peso_administracao_publica.parquet` (`11.140` linhas | `6` colunas)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge`, `nome_municipio`, `ano` | `string` | Identificação municipal e ano (`"2023"`). |
| `codigo_variavel`, `indicador` | `string` | `"526"` (participação do VAB da Adm. Pública no VAB da Adm. Pública do Brasil) e `"527"` (idem na UF). |
| `percentual` | `string` | Percentual de participação (pode conter `"..."`). |

### 4.5 `censo2022_cor_raca_sexo.parquet` (`66.840` linhas | `6` colunas)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge`, `nome_municipio`, `ano` | `string` | Identificação municipal e ano (`"2022"`). |
| `cor_raca` | `string` | `"Total"`, `"Branca"`, `"Preta"`, `"Amarela"`, `"Parda"`, `"Indígena"`. |
| `sexo` | `string` | `"Homens"`, `"Mulheres"`. |
| `populacao` | `string` | Contagem populacional do cruzamento (contém `"..."` em células suprimidas). |

### 4.6 `censo2022_taxa_alfabetizacao.parquet` (`5.570` linhas | `3` colunas)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge`, `nome_municipio` | `string` | Identificação municipal. |
| `taxa_alfabetizacao` | `string` | Percentual alfabetizado na faixa de 15 anos ou mais (ex: `"91.59"`). |

### 4.7 `censo2022_urbana_rural.parquet` (`22.280` linhas | `7` colunas)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge`, `nome_municipio`, `ano` | `string` | Identificação municipal e ano (`"2022"`). |
| `codigo_variavel`, `variavel` | `string` | `"93"` (População residente absoluta) e `"1000093"` (Percentual do total geral). |
| `situacao_domicilio` | `string` | `"Urbana"` ou `"Rural"`. |
| `valor` | `string` | Valor absoluto ou percentual conforme `codigo_variavel`. |

### 4.8 `censo2022_esgotamento_sanitario.parquet` (`11.140` linhas | `5` colunas)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge`, `nome_municipio`, `ano` | `string` | Identificação municipal e ano (`"2022"`). |
| `tipo_esgotamento` | `string` | `"Rede geral, rede pluvial ou fossa ligada à rede"` vs `"Não tinham banheiro nem sanitário"`. |
| `pct_domicilios` | `string` | Percentual de domicílios particulares permanentes ocupados. |

### 4.9 `censo2022_abastecimento_agua.parquet` (`5.570` linhas | `5` colunas)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_ibge`, `nome_municipio`, `ano` | `string` | Identificação municipal e ano (`"2022"`). |
| `forma_abastecimento` | `string` | `"Rede geral de distribuição"`. |
| `pct_rede_geral` | `string` | Percentual de domicílios atendidos pela rede geral de água. |

### 4.10 `depara_tse_ibge.parquet` (`1.498` linhas | `6` colunas — `01_bronze/data/`)
| Coluna | Tipo | Propósito |
| :--- | :--- | :--- |
| `codigo_tse` | `string` | Código municipal do TSE (5 dígitos, ex: `"40010"`). Cruza com `SG_UE` / `CD_MUNICIPIO`. |
| `codigo_ibge` | `string` | Código oficial do IBGE (7 dígitos, ex: `"3100104"`). Cruza com todas as tabelas IBGE. |
| `codigo_ibge_6` | `string` | Código IBGE sem dígito verificador (6 dígitos). |
| `uf` | `string` | `"MG"` (`853` municípios) ou `"SP"` (`645` municípios). |
| `nome_municipio_tse` | `string` | Nome oficial do município no cadastro do TSE. |
| `capital` | `string` | `"1"` (Capital) ou `"0"` (Interior). |
