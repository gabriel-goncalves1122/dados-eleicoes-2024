# 📊 Síntese Executiva das Conclusões — Eleições 2024 (MG & SP) × IBGE

Este diretório reúne a análise minuciosa dos resultados gerados na camada Gold ([03_gold/data](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/data)) e das visualizações interativas ([03_gold/analytics/output/index.html](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/analytics/output/index.html)), integrando **151.868 candidaturas únicas** do TSE 2024 em Minas Gerais e São Paulo aos indicadores demográficos e econômicos do **Censo 2022 e PIB Municipal do IBGE** em **1.498 municípios** (853 de MG e 645 de SP).

Os documentos foram organizados **por contexto analítico**, detalhando para cada tema: (i) a lógica de modelagem e cruzamento adotada, (ii) as conclusões gerais, (iii) as descobertas **não óbvias** ou contraintuitivas verificadas com controles estatísticos, (iv) exemplos reais nominais e (v) armadilhas metodológicas identificadas na base.

---

## 🗂️ Navegação por Contexto

| Contexto | Escopo & Gráficos Cobertos | Principal Achado Não Óbvio | Documento |
| :--- | :--- | :--- | :--- |
| **1. Finanças, ROI & Patrimônio** | Gráficos `01` a `06` (`datamart_candidatos_2024`) | Campanhas de prefeito acima de R$ 500 mil têm **menor** taxa de vitória (38,6%) que as de R$ 100k–500k (43,4%); quase metade (48%) dos 50 candidatos mais ricos perdeu. | [01_financas_roi_e_patrimonio.md](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/docs/conclusoes/01_financas_roi_e_patrimonio.md) |
| **2. Representatividade & Demografia** | Gráficos `00`, `07`, `08`, `09` (`candidatos` + `eleitoral_socioeconomico`) | Existe um **"Vale da Representatividade Feminina"** nas cidades de Grande Porte (100k–500k hab.: 13,3% de eleitas, pior que cidades <20k com 16,1%); mulheres recebem mais Fundo Público mediano que homens, mas ainda perdem por falta de doação privada e concentração em candidaturas de baixo retorno. | [02_representatividade_e_demografia.md](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/docs/conclusoes/02_representatividade_e_demografia.md) |
| **3. Economia Municipal & Escolaridade** | Gráficos `10` e `11` (`eleitoral_socioeconomico` + `candidatos`) | Mesmo controlando simultaneamente por **tamanho da população** e **PIB per capita** em regressão log-linear, a dependência da Administração Pública no VAB continua elevando o gasto eleitoral por habitante ($p = 7{,}2 \times 10^{-25}$), e a diferença aparente entre MG e SP desaparece ($p = 0{,}836$). | [03_economia_municipal_e_escolaridade.md](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/docs/conclusoes/03_economia_municipal_e_escolaridade.md) |
| **4. Estratégia de Gastos, Timing & Hegemonia** | Gráficos `12`, `13`, `14` (`despesas_2024` + `eleitoral_socioeconomico`) | **59,8% (R$ 1,10 bilhão)** de todo o gasto eleitoral foi contratado no **primeiro mês** de campanha (com pico absoluto no dia 16/08), e não na véspera da eleição; candidatos derrotados gastam proporcionalmente muito mais em **pessoal** (17,2% vs 12,8%) do que os eleitos. | [04_gastos_timing_e_hegemonia_partidaria.md](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/docs/conclusoes/04_gastos_timing_e_hegemonia_partidaria.md) |

---

## 🔢 Fotografia Macro dos Dados (MG + SP, 2024)

* **Universo Eleitoral (`02_silver/tse` → `03_gold`):**
  * **151.868** candidaturas únicas após deduplicação de 1º/2º turnos (`4.509` a Prefeito, `4.572` a Vice-Prefeito e `142.787` a Vereador).
  * **MG (853 municípios | 20,54 milhões de hab.):** `2.358` candidatos a Prefeito (`852` eleitos, taxa base de 36,1%) e `68.743` a Vereador (`8.526` eleitos, 12,4%).
  * **SP (645 municípios | 44,41 milhões de hab.):** `2.151` candidatos a Prefeito (`643` eleitos, taxa base de 29,9%) e `74.044` a Vereador (`7.047` eleitos, 9,52%).
* **Fluxo Financeiro Agregado:**
  * **R$ 1,993 bilhão** em receitas declaradas (`713.921` lançamentos na Silver), dos quais **R$ 1,425 bilhão (71,51%)** vieram de Fundo Público (FEFC + Fundo Partidário).
  * **R$ 1,839 bilhão** em despesas contratadas (`1.276.510` lançamentos na Silver).
  * **Concentração extrema nas metrópoles:** apenas as disputas para prefeito de **São Paulo (R$ 173,7 Mi)** e **Belo Horizonte (R$ 93,1 Mi)** responderam por **23,45%** (R$ 266,8 Mi) de todo o gasto de candidaturas a prefeito nos 1.498 municípios de MG e SP.

---

## 🧠 Como Pensamos a Leitura dos Resultados (Método Analítico)

Ao longo dos quatro contextos, evitamos tirar conclusões apenas olhando rankings absolutos ou médias simples. Aplicamos quatro princípios de investigação sobre os datamarts:

1. **Separação entre Efeito Mecânico (Escala/Denominador) e Efeito Comportamental:** Em municípios muito pequenos, custos fixos (contador, advogado, material mínimo) divididos por poucos eleitores inflam artificialmente métricas *per capita*. Sempre que uma variável municipal crescia em cidades menores (como dependência pública vs. gasto por habitante), testamos se o efeito sobrevivia **controlando pela população**.
2. **Média vs. Mediana em Distribuições de Cauda Pesada (*Power Law*):** Em finanças eleitorais, poucos candidatos de capitais puxam a média para cima. Por isso, comparamos a taxa de recebimento (`> R$ 0`), a **mediana** (candidato típico) e o **P90** (cauda superior).
3. **Diferenciação por Tipo de Pleito (Majoritário vs. Proporcional):** A lógica de Prefeito (vencedor único, `~30%` de chance média, campanha estruturada) é oposta à de Vereador (`~10%` de chance média, quase metade sem gasto declarado, forte peso de quociente partidário). Misturar os dois cargos gera falácias de agregação.
4. **Auditoria de Artefatos da Base antes de Concluir:** Quando encontramos anomalias extremas (ex.: candidata com R$ 400 mil de fundo público e 0 votos, ou candidatos a prefeito com mais votos que eleitores em uma eleição só), voltamos à Silver (`votacao_munzona_clean.parquet`) e à Bronze (`candidatos.parquet`) para distinguir **erros de interpretação** (soma de 1º + 2º turnos; candidaturas `#NULO` por falecimento/substituição) de **fenômenos políticos reais**.
