# Pipeline de Engenharia e Análise de Dados Eleitorais (TSE 2024 + IBGE)

Projeto acadêmico em **Arquitetura Medalhão 100% Parquet (ZSTD)** com **Camada Prata em Constelação (DuckDB)** e **Camada Ouro Temática Enxuta (8 datamarts de 10 a 20 colunas)** para análise das **Eleições Municipais de 2024 (Brasil — todos os municípios)** integradas ao **Censo 2022 e PIB Setorial do IBGE**.

---

## 🏛️ Estrutura do Projeto

```text
.
├── 00_instala_pacotes.R                         # Instalação de dependências CRAN
│
├── dados/                                       # Camadas de dados em Parquet único (ZSTD)
│   ├── bronze/                                  # Dados brutos padronizados (TSE, IBGE, De-Para)
│   ├── prata/                                   # Constelação: dim_*.parquet e fato_*.parquet
│   └── ouro/                                    # 8 datamarts temáticos enxutos (ouro_*.parquet)
│
├── src/                                         # Código-fonte do pipeline ETL
│   ├── config.R                                 # Caminhos e constantes centralizadas
│   ├── pipeline.R                               # Orquestrador central da esteira
│   ├── ingestao/                                # Bronze: ingestao_tse.R, ingestao_ibge.R, ingestao_depara.R
│   ├── limpeza/                                 # Prata (Constelação DuckDB): limpeza_ibge.R, limpeza_tse_candidatos.R, limpeza_tse_financas.R
│   └── modelagem/                               # Ouro (Temática DuckDB): ouro_*.R
│
├── analises/                                    # Análises estatísticas e visualizações
│   ├── pca/                                     # Atividade 03: atividade_03_pca.R e gráficos
│   ├── eda/                                     # Exploração inicial e validação de dados
│   ├── eleicoes/                                # 10 análises estatísticas nacionais (00_executar_todas_analises.R)
│   ├── painel/                                  # Painel executivo selecionado (KPIs, pizzas, colunas, séries e rankings)
│   └── eleicoes_legado/                         # Scripts visuais legados da fase MG & SP
│
├── apresentacao/                                # Deck HTML (frontend-slides, palco 1920x1080 + PNGs em assets/)
│   └── index.html                               # Abrir diretamente no navegador (atalhos: ← → Espaço T E F)
│
└── docs/                                        # Documentação e dicionário de dados
    ├── camadas/                                 # Documentação técnica das camadas
    └── catalogo/                                # gera_metadados.R + metadados JSON/Markdown
```

---

## 🚀 Como Executar

```r
# 1. Instalar dependências (primeira vez)
source("00_instala_pacotes.R")

# 2. Executar toda a esteira ou etapas específicas
source("src/pipeline.R")
executar_pipeline("tudo")       # Ingestão -> Limpeza -> Modelagem -> Catálogo
executar_pipeline("ingestao")   # Apenas camada Bronze
executar_pipeline("limpeza")    # Apenas camada Prata (Constelação)
executar_pipeline("modelagem")  # Apenas 8 Datamarts Ouro Temáticos
executar_pipeline("catalogo")   # Apenas dicionário de metadados
```

Ou via terminal (PowerShell / Bash) na raiz `Gabriel_Goncalves/`:

```bash
Rscript src/pipeline.R tudo
Rscript analises/pca/atividade_03_pca.R
Rscript analises/eleicoes/00_executar_todas_analises.R
Rscript analises/painel/00_executar_painel.R
```
