# Pipeline de Engenharia e Análise de Dados Eleitorais (TSE)

Repositório acadêmico desenvolvido para ingestão, processamento em larga escala, agregação analítica e visualização de dados de financiamento de campanha e desempenho eleitoral do Tribunal Superior Eleitoral (TSE) brasileiro.

---

## 🏛️ Arquitetura de Dados (Medallion Architecture)

O projeto segue a arquitetura em medalhão, garantindo rastreabilidade, integridade e alta performance através do **Apache Arrow**:

```text
tse/
├── data/
│   ├── 01_raw/          # [Bronze] Dados brutos originais e arquivos compactados (.zip, .csv)
│   ├── 02_silver/       # [Silver] Dados sanitizados, sem anomalias, em Parquet e CSV
│   │   ├── csv/         # Catálogos de dados e metadados
│   │   └── parquet/     # Arquivos colunares de alta performance
│   └── 03_gold/         # [Gold] Datamarts analíticos prontos para visualização e modelagem
│       ├── csv/
│       └── parquet/
│
└── scripts/
    ├── 01_extracao/     # Download automatizado de dados do TSE
    ├── 02_limpeza/      # Higienização de dados em streaming com Apache Arrow
    ├── 03_agregacao/    # Construção do Datamart cruzando receitas, despesas e votos
    ├── 04_visualizacao/ # Gráficos analíticos interativos (Plotly e ggplot2)
    └── 05_documentacao/ # Gerador automatizado de Data Catalog e Dicionário de Dados
```

---

## 🚀 Como Executar o Projeto

### 1. Pré-requisitos e Instalação de Pacotes
No console do R ou no RStudio, instale as dependências executando:

```r
source("00_instala_pacotes.R")
```

Os pacotes principais utilizados são:
- `tidyverse` (manipulação funcional de dados)
- `arrow` (processamento colunar e streaming em disco de bases de múltiplos gigabytes)
- `plotly` (gráficos analíticos interativos)
- `reactable` (tabelas dinâmicas)

---

### 2. Pipeline de Processamento (Passo a Passo)

Caso deseje reprocessar toda a esteira desde a extração:

1. **Extração:**
   ```bash
   Rscript tse/scripts/01_extracao/01_download_tse.R
   ```
2. **Limpeza e Sanitização (Silver):**
   ```bash
   Rscript tse/scripts/02_limpeza/01_limpeza_candidatos.R
   Rscript tse/scripts/02_limpeza/02_limpeza_receitas.R
   Rscript tse/scripts/02_limpeza/03_limpeza_despesas.R
   ```
3. **Agregação e Datamart (Gold):**
   ```bash
   Rscript tse/scripts/03_agregacao/01_cria_datamart_candidatos.R
   ```
4. **Catálogo e Governança:**
   ```bash
   Rscript tse/scripts/05_documentacao/01_gera_metadados.R
   ```

---

## 📊 Visualizações Analíticas Disponíveis

Os dados analíticos da camada Gold já estão versionados neste repositório. Para visualizar os gráficos interativos no RStudio Viewer, basta executar os scripts da pasta `tse/scripts/04_visualizacao/`:

- `01_roi_partidario.R`: Análise de ROI eleitoral por partido (Votos por Real investido).
- `02_desigualdade_fundo.R`: Concentração de Fundo Eleitoral público entre candidatos.
- `03_dispersao_geografica.R`: Pulverização municipal dos votos por candidato.
- `04_top20_partidos.R`: Maiores volumes financeiros por partido (Origem Pública vs Privada).
- `05_top_deputados_milionarios.R`: Maiores orçamentos de campanha e taxa de sucesso eleitoral.
- `06_extremos_custo_voto.R`: Candidatos com maior e menor custo unitário por voto.

---

## 📖 Dicionários de Dados

Cada diretório de dados (`02_silver` e `03_gold`) possui um arquivo `README.md` contendo a contagem exata de linhas e o esquema de colunas com seus respectivos tipos de dados, gerados automaticamente via Arrow.
