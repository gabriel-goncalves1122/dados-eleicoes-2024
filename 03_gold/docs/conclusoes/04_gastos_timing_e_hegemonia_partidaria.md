# 📅 Contexto 4: Estratégia de Gastos, Curva Temporal e Hegemonia Partidária

Este documento analisa os resultados dos gráficos `12`, `13` e `14` ([03_gold/analytics/](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/analytics)), apoiados por [datamart_despesas_2024.parquet](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/data/datamart_despesas_2024.parquet) (`13.213` linhas agregando `1.276.510` lançamentos fiscais da Silver) e [datamart_eleitoral_socioeconomico_2024.parquet](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet).

---

## 1. O Pensamento por Trás das Análises

Despesas eleitorais contam duas histórias que o saldo final isolado não mostra:
1. **Composição estratégica (`12`):** comparar valores absolutos entre eleitos e não eleitos é enviesado porque existem muito mais candidatos derrotados (`134.125`) do que eleitos (`17.743`). Por isso, normalizamos a **participação percentual dentro de cada grupo** sobre as Top 10 categorias (que cobrem quase todo o orçamento de R$ 1,84 bilhão) e observamos o diferencial em pontos percentuais (`diff_pp`).
2. **Dinâmica temporal (`13`):** analisar a data da despesa (`dt_despesa`) revela o comportamento operacional e contábil real das campanhas entre o início oficial (16/08/2024), o 1º turno (06/10/2024) e o 2º turno (27/10/2024).
3. **Geografia socioeconômica do poder (`14`):** cruzar quais partidos ganharam prefeituras com o **PIB per capita** e a **dependência da Administração Pública** mostra o nicho estrutural de cada legenda.

---

## 2. Conclusões Gerais

### 2.1 Para onde vão os R$ 1,84 bilhão das campanhas (Gráfico `12`)
Quatro rubricas concentram mais de **67%** de todo o gasto eleitoral em MG e SP:

| Categoria de Despesa | Eleitos (R$ Mi) | Não Eleitos (R$ Mi) | % Eleitos | % Não Eleitos | Diferença (`Eleitos - Não Eleitos`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **1. Publicidade por materiais impressos** | `146,0` | `239,0` | **`25,8%`** | `23,3%` | **`+2,49 pp`** |
| **2. Serviços prestados por terceiros** | `88,7` | `177,0` | `15,7%` | `17,3%` | `-1,62 pp` |
| **3. Despesas com pessoal** | `72,4` | `176,0` | `12,8%` | **`17,2%`** | **`-4,34 pp`** |
| **4. Atividades de militância e mobilização de rua** | `72,1` | `141,0` | `12,8%` | `13,8%` | `-1,06 pp` |
| **5. Impulsionamento de conteúdos (digital)** | `50,0` | `87,3` | `8,85%` | `8,53%` | `+0,32 pp` |
| **6. Serviços advocatícios** | `34,9` | `50,7` | `6,18%` | `4,95%` | **`+1,23 pp`** |
| **7. Publicidade por adesivos** | `31,9` | `43,6` | `5,64%` | `4,26%` | **`+1,38 pp`** |
| **8. Produção de programas de rádio/TV/vídeo** | `26,1` | `39,3` | `4,62%` | `3,84%` | `+0,78 pp` |
| **9. Serviços contábeis** | `22,8` | `34,2` | `4,03%` | `3,34%` | `+0,69 pp` |
| **10. Diversas a especificar** | `20,4` | `35,6` | `3,61%` | `3,48%` | `+0,13 pp` |

* Mesmo na era digital, **material impresso (santinhos/folhetos)** + **adesivos** ainda respondem por **31,4%** do orçamento dos eleitos (R$ 177,9 Mi) contra apenas **8,85%** em impulsionamento digital (R$ 50,0 Mi).

### 2.2 O mapa da hegemonia partidária: Centrão tradicional vs. PT/PRD vs. PL (Gráfico `14`)
Entre os 12 partidos com mais prefeituras conquistadas em MG e SP:
* **Liderança absoluta do PSD:** conquistou **350 prefeituras** (142 em MG e 208 em SP — quase o dobro do 2º colocado, **Republicanos** com 166, **PL** com 159 e **MDB** com 152).
* **Maior população governada:** embora o **MDB** seja o 4º em número de prefeituras (`152`), ele governa **15,1 milhões de habitantes** (puxado pela capital São Paulo, 11,45M hab.), superando o PSD (`13,0M` hab. em 350 cidades) e o PL (`8,85M` hab. em 159 cidades).

---

## 3. Conclusões Não Óbvias & Paradoxos

### 3.1 A Campanha "Acaba no Mês 1": 59,8% do dinheiro é contratado logo após a largada, não na véspera (Gráfico `13`)
**Senso comum:** "Os gastos de campanha crescem exponencialmente até a última semana antes da eleição (início de outubro)."  
**O que a série temporal diária (`13_curva_temporal_gastos_campanha.html`) revela:**
* A distribuição temporal é **fortemente concentrada no início da janela legal (`16/08` a `15/09`)**:
  * **Pré-campanha (`< 16/08`):** `R$ 39,6 Mi` (`2,15%`).
  * **Mês 1 (`16/08 a 15/09`):** **`R$ 1.100,0 Mi` (`59,8%` de toda a eleição!)**.
  * **Reta final do 1º Turno (`16/09 a 05/10`):** `R$ 611,0 Mi` (`33,2%`).
  * **Dia do 1º Turno (`06/10`):** `R$ 2,12 Mi` (`0,12%`).
  * **2º Turno (`07/10 a 27/10`):** `R$ 76,6 Mi` (`4,17%`).
  * **Pós-eleição (`> 27/10`):** `R$ 10,3 Mi` (`0,56%` — ajustes/fechamentos contábeis finais).
* **O choque do dia 16 de agosto (1º dia permitido pela Justiça Eleitoral):** Em **um único dia (`2024-08-16`)**, as campanhas contrataram **R$ 121 milhões em SP** e **R$ 64,3 milhões em MG** (**R$ 185,3 milhões em 24h**, mais de 10% de todo o ciclo eleitoral!). O segundo maior pico ocorreu exatamente na primeira quinzena de setembro (`2024-09-09`, data limite da prestação parcial de contas: **R$ 73,2 Mi em SP** e **R$ 42,9 Mi em MG**).
* **Por que isso acontece?** Porque a base registra **`dt_despesa` (data da contratação do serviço/fornecedor)**, e não o fluxo de caixa diário pago na boca do caixa. As campanhas assinam contratos fechados de agência, gráfica, equipe jurídica/contábil e cabos eleitorais para todo o período logo na abertura (`16/08`) e regularizam contratos antes da prestação parcial de contas (`09/09`), gerando picos contábeis gigantescos nesses marcos regulatórios.

---

### 3.2 Derrotados gastam proporcionalmente muito mais em *Folha/Pessoal* do que Eleitos (Gráfico `12`)
**Senso comum:** "Quem ganha gasta mais em digital ou em estrutura humana de rua."  
**O que a diferença proporcional (`diff_pp`) revela:**
* A maior diferença negativa para os eleitos é em **Despesas com pessoal**: **`12,8%`** entre eleitos contra **`17,2%`** entre não eleitos (**`-4,34 pp`**). Somando `Pessoal` + `Militância de rua` + `Terceiros`, não eleitos alocaram **48,3%** do orçamento contra **41,3%** dos eleitos.
* Em contrapartida, **eleitos alocaram proporcionalmente mais** em **Materiais impressos (`+2,49 pp`)**, **Adesivos (`+1,38 pp`)** e **Serviços advocatícios (`+1,23 pp`)** — impulsionamento digital teve diferença mínima (`+0,32 pp`: `8,85%` vs. `8,53%`).
* **Por que isso acontece?**
  1. Em campanhas grandes de capitais que perderam (como os R$ 84,8 Mi de Boulos ou os R$ 10+ Mi de candidatos derrotados em BH/SP/Guarulhos), há estruturas pesadas de folha de pessoal, militância paga e terceiros, enquanto muitos prefeitos vencedores em cidades médias e pequenas (inclusive em reeleição) mantêm campanhas de rua mais enxutas em folha fixa, com forte presença de material visual (adesivagem/impressos) e estrutura jurídica para defender a elegibilidade/diplomação.

---

### 3.3 Clivagem Socioeconômica dos Partidos: Quem governa as cidades ricas vs. as cidades dependentes do Estado (Gráfico `14`)
Ao cruzar os Top 12 partidos vencedores de prefeituras com a economia do IBGE, emergem **três blocos socioeconômicos nítidos**:

| Bloco Partidário | Partidos (Exemplos) | Prefeituras | PIB per Capita Mediano | % Adm. Pública Mediana | % Cidades Pequenas (`<20k`) |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Polo Econômico / Urbano** | **PL**, **PODE**, **PSD**, **REPUBLICANOS** | `159` / `56` / `350` / `166` | **`R$ 37,9k – R$ 42,0k`** | **`20,2% – 26,1%`** | `56,6% – 71,1%` |
| **Centrão Intermediário** | **PSDB**, **PP**, **MDB**, **UNIÃO** | `80` / `123` / `152` / `108` | `R$ 27,8k – R$ 32,0k` | `30,3% – 32,1%` | `70,7% – 78,8%` |
| **Interior Pequeno / Dependente do Estado** | **PT**, **PRD**, **AVANTE**, **SOLIDARIEDADE** | `39` / `44` / `62` / `36` | **`R$ 20,2k – R$ 28,9k`** | **`36,0% – 45,7%`** | `76,9% – 88,6%` |

* **Contraste extremo entre PL e PT nas prefeituras de MG e SP:**
  * O **PL** conquistou as cidades com o **maior PIB per capita mediano (`R$ 41.998`)**, **menor dependência da Adm. Pública (`20,2%`)** e **menor concentração em microcidades (`56,6%` `<20k`)** — forte desempenho no interior rico paulista e polos médios/grandes (ex.: Guarulhos/SP).
  * O **PT**, em 2024 em MG e SP, governou o polo oposto: apenas **39 prefeituras** com o **menor PIB per capita mediano (`R$ 20.220` — menos da metade do PL!)** e a **maior dependência mediana da Administração Pública (`45,7%`)**, embora ainda retenha duas das quatro metrópoles mineiras (Contagem e Juiz de Fora, que explicam seus 2,16M de habitantes governados em apenas 39 cidades).
  * O **PRD** apresentou a maior capilaridade em microcidades: **88,6%** de suas 44 prefeituras têm menos de 20 mil habitantes (`PIB per capita` mediano de R$ 25.029 e `43,7%` de dependência pública).
  * O **Avante** aparece como fenômeno regional mineiro: das **62 prefeituras** vencidas no recorte, **60 estão em Minas Gerais** (e apenas 2 em SP), concentradas em cidades pequenas (`79% <20k`).

---

## 4. Cuidados Metodológicos na Interpretação
* **Data de contratação $\neq$ data de desembolso (`13`):** `dt_despesa` reflete a emissão da nota/contrato registrado no SPCE do TSE. Os saltos em `16/08` e `09/09` representam picos contratuais/contábeis e prazos legais de prestação parcial, não necessariamente execução física no mesmo dia.
* **Subnotificação em candidaturas pequenas (`12`):** `71.040` candidaturas a vereador (quase metade!) registraram R$ 0 de gasto individual no datamart (muitas vezes porque o material gráfico foi pago pelo diretório partidário ou pelo candidato a prefeito na "dobradinha" e não lançado na conta individual do vereador), o que concentra o volume analisado nas campanhas com prestação própria ativa.
