# 🏛️ Contexto 3: Economia Municipal, Dependência da Máquina Pública e Escolaridade

Este documento analisa os resultados dos gráficos `10` e `11` ([03_gold/analytics/](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/analytics)), utilizando [datamart_eleitoral_socioeconomico_2024.parquet](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/data/datamart_eleitoral_socioeconomico_2024.parquet) e [datamart_candidatos_2024.parquet](file:///c:/Users/SEPLAN/Documents/UNIFEI/UNIVERSIDADE/R/03_gold/data/datamart_candidatos_2024.parquet).

---

## 1. O Pensamento por Trás das Análises

Para investigar se a **estrutura econômica local** altera o comportamento da disputa política, cruzamos as contas eleitorais do TSE com o **PIB Setorial do IBGE (`pct_adm_publica_vab_2021`)**, que mede qual fração da riqueza produzida na cidade vem da própria Administração Pública (prefeitura, serviços públicos, folha estatal) em contraste com indústria, agropecuária e serviços privados.

**A armadilha estatística que precisávamos testar:**  
Cidades muito dependentes do setor público costumam ser **pequenas** e **mais pobres**. Como campanhas têm um custo fixo mínimo, uma cidade de 2.000 habitantes tende naturalmente a ter gasto *per capita* maior do que uma de 500 mil. Portanto, a pergunta rigorosa não era apenas *"o gráfico 10 sobe?"*, mas sim: **a dependência da prefeitura ainda encarece a campanha *mesmo quando comparamos cidades do mesmo tamanho e riqueza*?**

---

## 2. Conclusões Gerais

### 2.1 Quanto maior o peso da Administração Pública na economia, maior o gasto eleitoral por habitante (Gráfico `10`)

Agrupando os 1.498 municípios em 4 faixas de dependência do VAB da Administração Pública:

| Faixa (% Adm. Pública no VAB) | MG: Municípios | MG: Pop. Mediana | MG: Gasto/Hab Mediano | SP: Municípios | SP: Pop. Mediana | SP: Gasto/Hab Mediano |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **1. Baixa (`< 15%`)** | `109` | `26.097` | `R$ 26,30` | `239` | `45.474` | `R$ 20,70` |
| **2. Moderada (`15% a 30%`)** | `214` | `16.060` | `R$ 23,20` | `231` | `12.669` | `R$ 27,10` |
| **3. Alta (`30% a 45%`)** | `239` | `7.214` | `R$ 30,20` | `127` | `5.083` | `R$ 35,50` |
| **4. Muito Alta (`> 45%`)** | `291` | `4.715` | **`R$ 36,80`** | `48` | `2.702` | **`R$ 49,90`** |

* **Em São Paulo**, o gasto mediano por habitante salta **2,41x** da faixa mais baixa (`R$ 20,70/hab`) para a faixa mais dependente (`R$ 49,90/hab`), enquanto a dependência média do Fundo Público sobe de `66,7%` para `77,8%`.
* **Em Minas Gerais**, mais de **62% dos municípios (`530` de `853`)** têm dependência *Alta* ou *Muito Alta* (`> 30%` do VAB), contra apenas **27% em São Paulo (`175` de `645`)**.
* **Exemplos extremos de gasto por habitante em cidades pequenas e dependentes:**
  * **Senador José Bento/MG** (`2.068` hab., `53,7%` Adm. Pública no VAB): **R$ 123,16 por habitante** (`R$ 254.687` gastos na cidade).
  * **Morro do Pilar/MG** (`3.133` hab., `56,6%` Adm. Pública no VAB): **R$ 122,54 por habitante** (`R$ 383.907` gastos).
  * **Córrego Novo/MG** (`2.875` hab., `55,9%` Adm. Pública no VAB): **R$ 103,21 por habitante** (`R$ 296.716` gastos).
  * **Arco-Íris/SP** (`2.044` hab., `44,3%` Adm. Pública no VAB): **R$ 110,19 por habitante** (`R$ 225.237` gastos).

### 2.2 Escolaridade superior amplia fortemente a vitória de Vereadores, mas quase não muda a de Prefeitos (Gráfico `11`)

| Escolaridade | Prefeito: Candidatos | Prefeito: Taxa Sucesso | Prefeito: Gasto Médio | Vereador: Candidatos | Vereador: Taxa Sucesso | Vereador: Gasto Médio |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **1. Até Fund. Incompleto** | `208` | `33,6%` | `R$ 68.556` | `19.106` | `8,49%` | `R$ 1.135` |
| **2. Fund. Comp. / Médio Inc.** | `316` | `32,3%` | `R$ 76.492` | `23.606` | `8,58%` | `R$ 1.817` |
| **3. Ensino Médio Completo** | `1.040` | `33,1%` | `R$ 105.240` | `56.575` | `10,2%` | `R$ 2.760` |
| **4. Superior Incompleto** | `215` | `27,9%` | `R$ 573.763` | `6.344` | `9,60%` | `R$ 8.220` |
| **5. Superior Completo** | `2.730` | **`33,7%`** | `R$ 317.357` | `37.156` | **`14,9%`** | `R$ 11.530` |

* **60,5% dos candidatos a Prefeito** já possuem Ensino Superior Completo (`2.730` de `4.509`), contra apenas **26,0% dos candidatos a Vereador** (`37.156` de `142.787`).
* Na **vereança**, candidatos com Superior Completo vencem **75% mais** que candidatos até o Fundamental Incompleto (`14,9%` vs. `8,49%`).

---

## 3. Conclusões Não Óbvias & Testes de Confundimento

### 3.1 A Dependência da Prefeitura encarece a campanha *mesmo controlando por população e PIB* (Teste Estatístico)
Para testar se o Gráfico `10` era apenas uma ilusão criada pelo tamanho pequeno das cidades, fizemos duas verificações:

1. **Controle estratificado apenas em cidades pequenas (`< 20 mil` habitantes — `1.059` municípios):**
   * Dependência `<15%` (`n = 113`, pop. mediana `8.815`): gasto mediano de **`R$ 29,00/hab`**.
   * Dependência `15–30%` (`n = 283`, pop. mediana `9.259`): **`R$ 28,70/hab`**.
   * Dependência `30–45%` (`n = 331`, pop. mediana `6.075`): **`R$ 33,40/hab`**.
   * Dependência `> 45%` (`n = 332`, pop. mediana `4.343`): **`R$ 38,50/hab`**.
2. **Regressão linear múltipla (`log(gasto_campanha_per_capita)` ~ `log(populacao_2022)` + `pct_adm_publica_vab_2021` + `log(pib_per_capita_reais)` + `sg_uf`):**
   * `log(populacao_2022)`: $\hat{\beta} = -0{,}1117$ ($t = -8{,}51$, $p = 4{,}1 \times 10^{-17}$) — confirma que o efeito de escala existe (cidades maiores têm gasto *per capita* menor).
   * `log(pib_per_capita_reais)`: $\hat{\beta} = +0{,}3549$ ($t = +10{,}09$, $p = 3{,}3 \times 10^{-23}$) — cidades mais ricas gastam mais por habitante.
   * **`pct_adm_publica_vab_2021`:** $\hat{\beta} = +0{,}0167$ ($t = +10{,}49$, **$p = 7{,}2 \times 10^{-25}$**) — **o efeito mais significativo do modelo!** Controlando simultaneamente por tamanho da cidade e PIB per capita, **cada +10 pontos percentuais de dependência da Administração Pública no VAB aumenta em ~18,1% o gasto eleitoral por habitante**.
   * **`sg_uf` (SP vs. MG):** $\hat{\beta} = +0{,}0056$ ($t = +0{,}21$, **$p = 0{,}836$**) — **estatisticamente nulo!**

**Dois insights profundos dessa regressão:**
1. **Explicação de Economia Política:** Quando a prefeitura é o principal motor econômico e empregador da cidade (`>45%` do PIB local), o controle da máquina pública vale proporcionalmente muito mais para os grupos locais — elevando o investimento eleitoral disputado por eleitor (*rent-seeking* eleitoral).
2. **MG e SP não têm "culturas eleitorais" diferentes nesse quesito:** A diferença agregada entre MG (`R$ 30,30/hab` mediano) e SP (`R$ 27,00/hab`) desaparece completamente ($p = 0{,}836$) quando controlamos por porte, PIB per capita e dependência do setor público!
3. **Por que MG sobe na faixa `<15%` (`R$ 26,30` vs. `R$ 23,20` na faixa `15–30%`) e Paulínia/SP aparece no Top 5?** Porque o modelo tem *dois* motores opostos atuando nas pontas: riqueza privada extrema em cidades-polo/mineradoras/petroquímicas (ex.: **Paulínia/SP**, com `2,35%` de Adm. Pública, PIB per capita de **R$ 606.741** e gasto de **R$ 116,34/hab**) versus dependência estatal extrema no interior (ex.: **Morro do Pilar/MG**, PIB per capita de **R$ 17.901**, `56,6%` Adm. Pública e **R$ 122,54/hab**).

---

### 3.2 O Falso Efeito da Escolaridade em Prefeitos vs. O Efeito Real (via Renda/Gasto) em Vereadores (Gráfico `11`)
**Senso comum:** "Ter diploma superior aumenta a chance de ser eleito porque o eleitor prefere candidatos mais escolarizados."  
**O que os dados realmente mostram:**
1. **Para Prefeito, a taxa de vitória é praticamente constante em todos os níveis de escolaridade!**
   * `Até Fundamental Incompleto`: **`33,6%`** de vitória.
   * `Ensino Médio Completo`: **`33,1%`**.
   * `Superior Completo`: **`33,7%`** (apenas `0,1 pp` acima de quem não completou o fundamental!).
   * E quem tem `Superior Incompleto` teve a **menor taxa de vitória (`27,9%`)** apesar de apresentar o **maior gasto médio (`R$ 573.763`)** — distorcido por candidatos multimilionários/famosos em capitais (ou candidatos de grandes centros sem diploma concluído).
2. **Para Vereador, o salto de `8,5%` para `14,9%` não vem apenas do diploma — vem de dinheiro e patrimônio:**
   * Vereadores com Superior Completo gastaram em média **R$ 11.530** (mediana `R$ 1.000`) e declararam patrimônio mediano de **R$ 72.000** (com R$ 8.403 de fundo público médio).
   * Vereadores sem Superior Completo gastaram em média **R$ 2.584** (mediana **`R$ 0`**!), tiveram patrimônio mediano de **R$ 12.000** (6x menor) e R$ 1.981 de fundo público médio (4,2x menor).
   * Ou seja: o diploma funciona na vereança fortemente como **proxy de capital socioeconômico e acesso a financiamento de campanha** (além de profissões de alta capilaridade como advogados, médicos e professores), e não como critério isolado do eleitor.
