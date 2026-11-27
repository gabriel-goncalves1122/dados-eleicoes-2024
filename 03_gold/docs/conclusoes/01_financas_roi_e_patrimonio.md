# 💰 Contexto 1: Finanças de Campanha, ROI Partidário, Fundo Público e Patrimônio

Este documento analisa os resultados dos gráficos `01` a `06` ([03_gold/analytics/](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/analytics)), construídos sobre [datamart_candidatos_2024.parquet](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/data/datamart_candidatos_2024.parquet) e [receitas_clean.parquet](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/02_silver/data/tse/receitas_clean.parquet).

---

## 1. O Pensamento por Trás das Métricas

Em ciência de dados eleitorais, olhar apenas "quem arrecadou mais" ou "quem gastou mais" é insuficiente porque o volume financeiro absoluto depende do tamanho da cidade e do número de candidatos lançados. Para isolar **eficiência**, **concentração** e **poder real de conversão**, o datamart derivou três métricas-chave:
1. **`custo_por_voto` (`total_gasto / total_votos`):** mede quanto custou, em média, cada voto obtido.
2. **`pct_fundo_publico` (`total_fundo_publico / total_arrecadado * 100`):** mede o grau de dependência de dinheiro estatal versus captação privada/própria.
3. **Taxa de sucesso partidária (`total_eleitos / total_candidatos`):** cruza eficiência financeira com vitória real nas urnas.

---

## 2. Conclusões Gerais (O Quadro Principal)

### 2.1 O Estado financia mais de 71% das eleições, mas com perfis partidários opostos (Gráfico `04`)
* Dos **R$ 1,993 bilhão** arrecadados em MG e SP, **R$ 1,425 bilhão (71,51%)** veio de recursos públicos (FEFC + Fundo Partidário), **R$ 361 milhões (18,1%)** de pessoas físicas e **R$ 128 milhões (6,44%)** de recursos próprios dos candidatos.
* **Polarização da matriz de financiamento entre os Top 20 partidos:**
  * **Hiperdependentes de fundo público:** **PSOL** (`95,3%` público — R$ 102,7 Mi de R$ 108 Mi totais), **PC do B** (`92,8%`), **PT** (`86,8%` — R$ 194,5 Mi de R$ 224 Mi) e **PL** (`86,1%` — R$ 257,7 Mi de R$ 299 Mi).
  * **Base privada/própria expressiva:** **NOVO** teve apenas **35,5%** de fundo público (R$ 10,8 Mi públicos vs. R$ 19,6 Mi privados) e **PRTB** apenas **10,3%** (R$ 1,36 Mi público vs. R$ 11,94 Mi privados, puxado por campanhas autofinanciadas/doações como Pablo Marçal).
  * **Centrão municipalista equilibrado:** **PSD** (`62,0%` público, mas com R$ 79,7 Mi de recursos privados — o maior volume privado absoluto entre todos os partidos), **MDB** (`69,8%`), **PP** (`61,7%`) e **Republicanos** (`65,3%`).

### 2.2 O retorno eleitoral por partido (ROI) separa "máquinas municipais" de "partidos de alta queima de caixa" (Gráfico `01`)
Entre os 10 partidos que mais elegeram prefeitos em MG e SP (mediana do grupo: **38,8%** de sucesso e **R$ 26,70/voto**):
* **Melhor quadrante (alta vitória + baixo custo/voto):**
  * **PSD** foi o grande vencedor estrutural: **350 prefeitos eleitos** em 684 candidaturas (**51,2% de sucesso**!) a um custo médio de apenas **R$ 23,30/voto**.
  * **MDB** obteve o menor custo por voto agregado entre os grandes (**R$ 15,60/voto** para 7,72 milhões de votos, 152 eleitos, 38,3% de sucesso) e **PP** entregou **41,8% de sucesso** (123 eleitos) com **R$ 26,30/voto**.
* **Menor eficiência relativa no Top 10:**
  * **PRD** teve o voto mais caro (**R$ 39,10/voto**, 32,1% de sucesso) e **Avante** também pagou caro por voto (**R$ 36,20/voto**), embora com alta taxa de conversão local (**42,5%** de sucesso em cidades menores de MG).
  * **PL** teve o maior gasto agregado para prefeito do Top 10 (**R$ 171,5 Mi** e **81,4%** de dependência média do fundo público), mas taxa de vitória abaixo da mediana (**34,5%** — 159 eleitos em 461 disputas).

### 2.3 Mediana do custo por voto de prefeitos eleitos e extremos de 220x (Gráfico `06`)
Considerando os prefeitos eleitos com pelo menos 500 votos e gasto positivo, o custo **mediano** foi de **R$ 26,35/voto** (média de **R$ 30,73/voto**), mas a dispersão vai de menos de R$ 1 a mais de R$ 170 por voto:
* **Mais caros (todos em cidades muito pequenas, onde custos fixos + disputas polarizadas inflam o valor por eleitor):**
  * **Terezinha Salesse (PSDB — Bento de Abreu/SP):** **R$ 171,57/voto** (R$ 109.290 para 637 votos).
  * **Palitinho (PL — Mombuca/SP):** **R$ 147,02/voto** (R$ 164.372 para 1.118 votos).
  * **Reginaldo Silva (PL — Comendador Gomes/MG):** **R$ 131,77/voto** (R$ 165.110 para 1.253 votos).
* **Mais econômicos (cidades médias/grandes com forte capital político prévio ou reeleição consensual):**
  * **Gleidson Azevedo (NOVO — Divinópolis/MG):** **R$ 0,77/voto** (gastou apenas R$ 63.988 e recebeu 83.298 votos).
  * **Cride (PSDB — Biquinhas/MG):** **R$ 1,41/voto** (R$ 1.990 para 1.410 votos).
  * **Helinho Zanatta (PSD — Piracicaba/SP):** **R$ 4,55/voto** mesmo em uma cidade grande (R$ 731.174 para 160.697 votos).

---

## 3. Conclusões Não Óbvias & Paradoxos

### 3.1 O Paradoxo do Orçamento Milionário: gastar mais de R$ 500 mil *reduz* a probabilidade de vitória (Gráfico `05`)
**Senso comum:** "Quem tem mais dinheiro na campanha ganha a eleição."  
**O que os dados mostram:**
1. Entre as **25 maiores campanhas de prefeito** de MG e SP (todas acima de R$ 4,69 milhões), **64% perderam (16 de 25)** e apenas **36% venceram (9 de 25)**!
   * **Exemplos marcantes:** Em São Paulo, **Guilherme Boulos (PSOL)** liderou o ranking de gastos com **R$ 84,85 milhões** e perdeu para **Ricardo Nunes (MDB)**, que gastou **R$ 53,91 milhões** (36% menos). Em Belo Horizonte, **Carlos Viana (PODE)** gastou **R$ 10,08 milhões** e obteve apenas **12.712 votos** — um custo impressionante de **R$ 792,57 por voto**! **Mauro Tramonte (REPUBLICANOS)** gastou **R$ 12,84 Mi** em BH (R$ 66,51/voto) e também ficou fora do 2º turno.
2. Analisando **todos os 4.509 candidatos a prefeito** por faixas de orçamento, observa-se uma **curva em U invertido (retorno marginal decrescente)**:
   * `R$ 0`: **0%** de sucesso (0 de 115) — sem o mínimo financeiro, não há viabilidade.
   * `R$ 1 a R$ 5 mil`: **1,94%** (2 de 103).
   * `R$ 5k a R$ 20k`: **6,21%** (19 de 306).
   * `R$ 20k a R$ 100k`: **31,6%** (645 de 2.042).
   * **`R$ 100k a R$ 500k`: 43,4%** (709 de 1.632) — **pico de taxa de vitória!**
   * **`>= R$ 500k`: cai para 38,6%** (120 de 311).

**Por que isso acontece (o pensamento analítico):**  
Não significa que dinheiro atrapalha; trata-se de **viés de seleção por competitividade**. Campanhas acima de R$ 500 mil ocorrem majoritariamente em grandes municípios e capitais, onde **múltiplos adversários também gastam milhões** e apenas 1 cadeira existe. O dinheiro compra visibilidade para *entrar na disputa* (sem pelo menos R$ 20k–100k a chance desaba), mas acima do patamar de entrada da cidade ele enfrenta retornos marginais decrescentes.

---

### 3.2 O Mito da Riqueza Pessoal: 48% dos 50 candidatos mais ricos perderam (Gráfico `03`)
**Senso comum:** "Candidatos multimilionários vencem porque financiam a própria máquina."  
**O que os dados mostram:**
* Entre os **50 candidatos a prefeito com maior patrimônio declarado**, **26 venceram (52%) e 24 perderam (48%)**.
* Olhando para toda a base de prefeitos com patrimônio e votos positivos, a correlação de postos de Spearman entre patrimônio declarado e votos é fraca ($\rho = 0{,}2335$).
* **Exemplos do Top 10 mais ricos:**
  * **1º — João Pinheiro (PRTB — Marília/SP):** declarou **R$ 2,851 bilhões**, gastou R$ 457,7 mil e teve apenas **3.397 votos** (não eleito).
  * **2º — Pablo Marçal (PRTB — São Paulo/SP):** declarou **R$ 169,5 milhões**, gastou R$ 7,74 Mi, teve **1,719 milhão de votos** (não eleito, fora do 2º turno).
  * **3º — Ruy Muniz (PSB — Montes Claros/MG):** declarou **R$ 158,9 milhões**, gastou R$ 550 mil e teve 23.353 votos (não eleito).
  * **7º — Tarcísio Ferreira (PV — Águas da Prata/SP):** declarou **R$ 70,9 milhões**, teve 801 votos (não eleito).
  * Em contraste, **Geovânio (PSD — Pimenta/MG)** declarou R$ 136,9 Mi e venceu gastando R$ 64,9 mil; **Zezinho Gimenez (MDB — Sertãozinho/SP)** declarou R$ 78,4 Mi e venceu com 57.354 votos.
* **Por que patrimônio ajuda só até certo ponto?** Entre quem declara `R$ 0` de patrimônio, a taxa de vitória para prefeito é **16,9%** (provavelmente candidatos menos estabelecidos); sobe para **35,6%** na faixa de `R$ 100k–500k` e **37,1%** em `R$ 500k–2M`, mas praticamente estagna depois disso (cai para **34,0%** em `R$ 2M–10M` e chega a **51,1%** só no pequeno grupo `>= R$ 10M` — 47 eleitos em 92). Patrimônio pessoal funciona mais como *proxy* de inserção social/empresarial até ~R$ 500 mil do que como combustível eleitoral direto.

---

### 3.3 O Paradoxo do Violin Plot no Fundo Público: mulheres têm *mediana maior* entre recebedoras, mas ainda perdem muito mais (Gráfico `02`)
**Senso comum:** "O Fundo Público dá menos dinheiro para mulheres e pretos/pardos do que para homens brancos."  
**O que o Violin Plot (`02_desigualdade_fundo.html`) realmente revela:**
1. Na **escala geral de recebedores** ($\ge$ R$ 100 de fundo público):
   * **Para Prefeito:** **91,0%** das mulheres receberam fundo (mediana entre recebedoras: **R$ 115.000**; média: R$ 283.053) contra **86,4%** dos homens (mediana: **R$ 60.000**; média: R$ 222.047).
   * **Para Vereador:** **38,3%** das mulheres receberam fundo (mediana entre recebedoras: **R$ 2.140**; média: R$ 11.201) contra **34,1%** dos homens (mediana: **R$ 1.400**; média: R$ 10.290).
   * Por **cor/raça** (entre recebedores $\ge$ R$ 100): **Mulheres Pretas** tiveram média de **R$ 21.686** (mediana R$ 3.000) e **Mulheres Brancas** média de **R$ 22.366** (mediana R$ 2.475), enquanto **Homens Brancos** apresentaram a **maior cauda superior** (média de **R$ 40.892** e P90 de **R$ 50.000**, embora mediana de R$ 2.000), e **Mulheres Pardas** ficaram com os menores valores médios entre as mulheres (**R$ 11.434**, P90 R$ 15.893).
2. **Onde está a desigualdade real que o gráfico esconde por trás da média?**
   * Primeiro, **assimetria de cauda**: entre homens brancos, o P90 chega a R$ 50.000 e a média é quase o dobro da das mulheres brancas (R$ 40,9k vs. R$ 22,4k), porque os maiores cheques nas capitais vão para homens já detentores de mandato.
   * Segundo, **61,7% das vereadoras e 65,9% dos vereadores recebem R$ 0 de fundo público** (a mediana *geral* de vereadores é **R$ 0** para ambos os sexos; o filtro `>= 100` do gráfico oculta essa massa de candidaturas sem fundo!).
   * Terceiro, o **dinheiro privado compensa para os homens**: na média geral de vereadores, homens captam **R$ 2.643 de recursos privados** contra apenas **R$ 1.401** das mulheres (quase o dobro!). Isso faz com que a mulher dependa **74,8%** do fundo público na vereança (e **87,7%** na prefeitura), ficando vulnerável à distribuição partidária.

---

### 3.4 A Anomalia de Alto Fundo / Baixíssima Votação (Auditoria de Dados)
Ao cruzar `total_fundo_publico >= 50.000` com `total_votos <= 50` entre candidatos a **Vereador**, encontramos **25 casos** que somam **R$ 2,01 milhões** em fundo público:
* **80% são mulheres (20 de 25)**, somando **R$ 1.625.790** (média de 29,7 votos), contra 5 homens (R$ 381.592, média de 30,6 votos).
* **A importância de checar a Bronze antes de acusar:** O caso mais extremo em valor nominal — **Ana Paula Rossi (PL — Osasco/SP)**, com **R$ 400.000** de fundo público e **0 votos** — aparece na Bronze com `DS_SIT_TOT_TURNO = #NULO` (falecimento/substituição antes do pleito, não se trata de "candidatura laranja" que foi às urnas).
* Porém, os outros **24 casos concorreram efetivamente às urnas** (`NÃO ELEITO` ou `SUPLENTE`), com destaques concentrados por município/partido:
  * **Paulínia/SP:** **4 candidatas** receberam entre R$ 60 mil e R$ 104,4 mil e tiveram de **20 a 43 votos** (ex.: *Tania Baiana - Solidariedade*: R$ 104.430 / 23 votos; *Gi Souza - Solidariedade*: R$ 100.298 / 20 votos; *Juliana Monteiro - Cidadania*: R$ 88.400 / 43 votos; *Sil Garcia - Cidadania*: R$ 60.000 / 42 votos).
  * **Araguari/MG:** **3 candidatas do PL** (*Eliane Marcondes*, *Aline Marques* e *Detinha do Triângulo*) receberam **R$ 50.000 cada** e obtiveram **29, 19 e 36 votos**, respectivamente.
  * **Márcia Zolla (PRD — Barrinha/SP):** recebeu **R$ 52.106** e obteve **5 votos** (custo público superior a R$ 10.400 por voto!).

---

## 4. Cuidado Metodológico na Leitura de `custo_por_voto` (2º Turno)

No script [01_cria_datamart_candidatos.R](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/scripts/01_cria_datamart_candidatos.R), `total_votos` agrega `votacao_munzona_clean.parquet` por `sq_candidato` **somando 1º e 2º turnos**:
* Por isso, no gráfico `05`, **Ricardo Nunes** aparece com `5.194.249` votos (`1.801.139` no 1ºT + `3.393.110` no 2ºT) e **Guilherme Boulos** com `4.100.028` (`1.776.127` no 1ºT + `2.323.901` no 2ºT). O mesmo ocorre com **Fuad Noman** (`336.442 + 670.574 = 1.007.016`) e **Bruno Engler** (`435.853 + 577.537 = 1.013.390`) em BH.
* **Implicação:** Para candidatos que foram ao 2º turno, `custo_por_voto` divide o gasto total dos dois turnos pela soma dos votos dos dois turnos (contando o eleitor duas vezes). Ao comparar o custo por voto de uma capital com 2º turno (R$ 10,38/voto de Ricardo Nunes) com o de uma cidade de turno único, essa diferença de denominador deve ser explicitada.
