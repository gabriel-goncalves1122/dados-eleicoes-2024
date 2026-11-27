# ⚖️ Contexto 2: Representatividade de Gênero e Raça — Do Censo 2022 às Urnas de 2024

Este documento analisa os resultados dos gráficos `00`, `07`, `08` e `09` ([03_gold/analytics/](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/analytics)), integrando [datamart_candidatos_2024.parquet](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/data/datamart_candidatos_2024.parquet) e [datamart_eleitoral_socioeconomico_2024.parquet](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet).

---

## 1. O Pensamento por Trás do Cruzamento (TSE × Censo 2022)

Olhar apenas a porcentagem de mulheres ou negros eleitos sem uma **linha de base demográfica** leva a interpretações distorcidas — especialmente ao comparar Minas Gerais e São Paulo, que possuem composições raciais muito distintas.
* Por isso, o pipeline calcula o **Gap de Representatividade em pontos percentuais (`pp`)**:
  $$\text{Gap} = \%_{\text{Urnas}} - \%_{\text{Censo 2022}}$$
  Um gap de `-35 pp` significa que aquele grupo tem 35 pontos percentuais a menos de participação nos assentos eleitos do que na população real daquele mesmo município.
* Além disso, em vez de olhar apenas o resultado final, estruturamos um **Funil de Representatividade** em 4 estágios (População $\rightarrow$ Candidaturas $\rightarrow$ Vereadoras $\rightarrow$ Prefeitas) e quebramos o gap por **5 faixas de porte populacional**.

---

## 2. Conclusões Gerais

### 2.1 O Funil da Representatividade Feminina quebra após a cota de 30% (Gráfico `07`)
A presença feminina cai drasticamente a cada degrau de poder, com comportamento quase idêntico nos dois estados:

| Estágio do Funil | Minas Gerais (MG) | São Paulo (SP) | Leituras |
| :--- | :---: | :---: | :--- |
| **1. População (Censo 2022)** | `51,2%` | `51,8%` | Maioria demográfica em ambos os estados. |
| **2. Candidaturas (Cota 30%)** | `33,6%` | `34,2%` | Partidos cumprem a cota legal mínima (~33-34%), mas pouco além dela. |
| **3. Vereadoras Eleitas** | `15,6%` | `17,3%` | Queda de mais de metade em relação às candidaturas! |
| **4. Prefeitas Eleitas** | **`8,1%`** | **`10,9%`** | No Executivo (cargo majoritário sem cota), menos de 1 em cada 9 cidades é governada por mulher. |

### 2.2 Sobre-representação branca e sub-representação parda/preta nos dois estados (Gráfico `08`)
Entre as 151.868 candidaturas (`00`), `55,6%` se declararam **Brancas** (`84.492`), `31,5%` **Pardas** (`47.842`), `11,7%` **Pretas** (`17.752`), `0,38%` **Amarelas** (`583`) e `0,13%` **Indígenas** (`197`). Quando comparamos a **população real (ponderada)** com os **eleitos (ponderados)** em cada estado:

| Cor / Raça | MG — Censo 2022 | MG — Eleitos 2024 | Gap MG | SP — Censo 2022 | SP — Eleitos 2024 | Gap SP |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Branca** | `41,1%` | **`54,5%`** | `+13,4 pp` | `57,8%` | **`75,8%`** | `+18,0 pp` |
| **Parda** | `46,8%` | `36,7%` | `-10,1 pp` | `33,0%` | `17,8%` | `-15,2 pp` |
| **Preta** | `11,8%` | `7,65%` | `-4,15 pp` | `7,99%` | `5,38%` | `-2,61 pp` |

* Embora Minas Gerais tenha população majoritariamente negra/parda (`58,6%` somando pretos e pardos no Censo), **54,5% dos eleitos são brancos**.
* Em São Paulo, apesar de brancos serem maioria (`57,8%`), eles ocupam **3 em cada 4 cadeiras (`75,8%`)**, comprimindo a participação de pessoas pardas para quase metade do seu peso populacional (`17,8%` vs. `33,0%`).

---

## 3. Conclusões Não Óbvias & Paradoxos

### 3.1 O "Vale da Representatividade Feminina" nas Cidades de Médio e Grande Porte (Gráfico `09`)
**Senso comum:** "Cidades pequenas do interior são mais conservadoras e elegem menos mulheres; metrópoles e cidades grandes são mais progressistas e elegem mais."  
**O que os dados realmente mostram (e contrariam parcialmente):**
A curva de mulheres eleitas por porte populacional **não é crescente** — ela forma um **vale acentuado nas cidades de Grande Porte (100 mil a 500 mil habitantes)**:

| Porte do Município | Nº Municípios | Mulheres Censo | Mulheres Eleitas | Gap Médio |
| :--- | :---: | :---: | :---: | :---: |
| **Pequeno Porte I (<20k)** | `1.059` | `49,6%` | `16,1%` | `-33,5 pp` |
| **Pequeno Porte II (20k–50k)** | `230` | `50,4%` | `15,6%` | `-34,8 pp` |
| **Médio Porte (50k–100k)** | `97` | `51,1%` | `16,0%` | `-35,1 pp` |
| **Grande Porte (100k–500k)** | `99` | `51,7%` | **`13,3%`** | **`-38,4 pp` (Pior faixa!)** |
| **Metrópole (>500k)** | `13` | `52,4%` | `18,7%` | `-33,7 pp` |

* **Em São Paulo, o fenômeno é ainda mais forte:** nas cidades `<20k` as mulheres ocupam **18,0%** das vagas, mas esse índice vai caindo conforme a cidade cresce até atingir **apenas 12,9%** nas cidades de `100k–500k` (gap de **`-38,8 pp`**) e só `15,6%` nas metrópoles paulistas!
* **Exemplos chocantes de cidades grandes com ZERO mulheres eleitas em 2024:**
  * **Mauá/SP (418 mil hab., 25 eleitos):** `33,8%` de candidatas mulheres $\rightarrow$ **0% eleitas** (`gap -51,9 pp`).
  * **Suzano/SP (307 mil hab., 21 eleitos):** `32,9%` de candidatas $\rightarrow$ **0% eleitas** (`gap -51,7 pp`).
  * **Sumaré/SP (280 mil hab., 23 eleitos):** `34,7%` de candidatas $\rightarrow$ **0% eleitas**.
  * **Cotia/SP (274 mil hab., 19 eleitos):** `34,7%` de candidatas $\rightarrow$ **0% eleitas**.
  * **Ibirité/MG (171 mil hab., 17 eleitos)**, **Atibaia/SP (159 mil hab., 13 eleitos)**, **Itanhaém/SP (112 mil hab., 12 eleitos)**, **Paulínia/SP (111 mil hab., 19 eleitos)** e **Poá/SP (104 mil hab., 15 eleitos)** também terminaram com **ZERO mulheres eleitas**!
  * E em **São José do Rio Preto/SP (480 mil hab., 25 eleitos)** apenas **1 mulher** foi eleita (**4,0%**).
* **Por que isso acontece?**
  * Em cidades **muito pequenas (`<20k`)**, as cadeiras da câmara são vencidas com poucos votos e forte laço comunitário/familiar local, permitindo maior entrada de mulheres (inclusive em prefeituras: 100 prefeitas eleitas em `<20k`, `9,5%`).
  * Nas **cidades de `100k–500k`** (cinturões metropolitanos e polos regionais), a política já é altamente profissionalizada, disputada por máquinas partidárias masculinas consolidadas e alto investimento privado — mas ainda **sem** a visibilidade midiática, o voto ideológico/programático e os grandes orçamentos de Fundo Eleitoral que impulsionam algumas vereadoras e prefeitas nas **metrópoles (`>500k`)** (como **Marília Campos** em Contagem/MG e **Margarida Salomão** em Juiz de Fora/MG, únicas 2 prefeitas eleitas entre as 13 metrópoles de MG+SP — ambas em MG, nenhuma das 9 metrópoles de SP elegeu prefeita!).

---

### 3.2 O Contraste Racial Inverso entre MG e SP nas Metrópoles (Gráfico `09`)
Enquanto o gap feminino piora nas cidades de `100k–500k`, o comportamento da representatividade negra/indígena **inverte de comportamento entre os dois estados**:
* Em **Minas Gerais**, a participação de pretos, pardos e indígenas entre os eleitos cai abruptamente justamente nas **4 metrópoles (`>500k`)**: passa de `44,6%` (`<20k`) e `46,1%` (`100k–500k`) para apenas **`34,7%`** nas metrópoles (pior gap racial de MG: **`-19,9 pp`** frente aos 54,6% do Censo!).
* Em **São Paulo**, o melhor desempenho relativo ocorre nas cidades de **`100k–500k`** (`29,3%` de eleitos negros/indígenas frente a `40,7%` do Censo, menor gap estadual: **`-11,4 pp`**), enquanto os piores gaps ocorrem justamente nas cidades pequenas (`<20k`: `21,7%` eleitos vs. `40,0%` no Censo, **`-18,3 pp`**).
* **Conclusão não óbvia:** Não existe uma regra única de "urbanização = maior inclusão". Em SP, o interior pequeno é racialmente mais excludente que as cidades médias-grandes; em MG, o poder metropolitano concentra uma elite política significativamente mais branca do que o interior mineiro.

---

### 3.3 A Assimetria de Conversão Voto-Candidatura entre Homens e Mulheres
Ao cruzar o funil de gênero com os dados de financiamento e votos no `datamart_candidatos_2024`:
* **Para Vereador:**
  * Homens (`92.852` candidatos): média de **271 votos** (mediana **94 votos**) $\rightarrow$ **14,0%** de taxa de vitória (`13.017` eleitos).
  * Mulheres (`49.920` candidatas): média de **150 votos** (mediana **38 votos**) $\rightarrow$ **5,12%** de taxa de vitória (`2.556` eleitas).
  * Ou seja, mesmo sendo **35% das candidaturas**, as mulheres têm **2,7x menos chance** de vencer na vereança, e a mediana de votos de uma candidata mulher (38 votos) é **menos da metade** da de um candidato homem (94 votos).
* **Por que isso ocorre junto com maior média de Fundo Público?**
  * Muitas chapas lançam mulheres apenas para cumprir a cota de 30% (puxando a mediana de votos para baixo), enquanto os homens mantêm **quase o dobro de financiamento privado** (`R$ 2.643` vs. `R$ 1.401` na média de vereadores; `R$ 59.072` vs. `R$ 35.970` na média de prefeitos) e maior capital eleitoral prévio (reeleição).

---

## 4. Cuidados Metodológicos na Interpretação
* **Média simples vs. ponderada nos gráficos `08` e `09`:** No gráfico `08` (comparação estadual MG vs. SP), usamos **média ponderada** pela `populacao_2022` (para o Censo) e por `total_eleitos` (para os eleitos), refletindo o peso demográfico real de cada estado (ex.: a capital São Paulo pesa proporcionalmente mais). Já no gráfico `09` (curva por porte), usamos a **média não ponderada entre os municípios** de cada faixa para medir o padrão típico da *cidade* daquele porte, evitando que São Paulo/BH dominem sozinhas suas categorias.
* **Autodeclaração TSE vs. IBGE:** Tanto o Censo 2022 quanto o cadastro do TSE baseiam-se em autodeclaração, mas no TSE há `984` candidaturas sem informação (`NÃO INFORMADO` / `NÃO DIVULGÁVEL`), que são mantidas no denominador de `total_candidatos` na Silver/Gold; o impacto é residual (`0,66%`).
