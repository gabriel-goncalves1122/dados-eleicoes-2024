# Pipeline de Engenharia e Análise de Dados Eleitorais (TSE 2024 + IBGE)

Projeto acadêmico enxuto em **Arquitetura Medalhão 100% Parquet (ZSTD)** para ingestão, higienização colunar com **Apache Arrow**, modelagem analítica e visualização interativa das **Eleições Municipais de 2024 (MG & SP)** integradas ao **Censo 2022 e PIB Setorial do IBGE**.

---

## 🏛️ Estrutura do Projeto (Enxuta e 100% Parquet)

```text
.
├── 00_instala_pacotes.R                   # Instalação de dependências CRAN
├── utils_paths.R                          # Resolução dinâmica da raiz do projeto
├── run_pipeline.R                         # Orquestrador central da esteira
│
├── 01_bronze/                             # [Bronze] Ingestão direta para Parquet
│   ├── scripts/
│   │   ├── 01_ingestao_tse.R              # Extrai MG & SP do CDN do TSE direto para .parquet
│   │   ├── 02_ingestao_ibge.R             # Coleta unificada SIDRA (Censo 2022 + PIB Setorial)
│   │   └── 03_ingestao_depara.R           # Mapeamento TSE (5d) <-> IBGE (7d) em .parquet
│   └── data/
│       ├── ibge/                          # 9 tabelas .parquet do IBGE/SIDRA
│       ├── tse/                           # candidatos, bens, votacao, receitas, despesas (.parquet)
│       └── depara_tse_ibge.parquet
│
├── 02_silver/                             # [Silver] Higienização Colunar
│   ├── scripts/
│   │   ├── 01_limpeza_tse_candidatos.R    # Candidatos e Votação Nominal
│   │   ├── 02_limpeza_tse_financas.R      # Receitas, Despesas Contratadas e Bens
│   │   └── 03_limpeza_ibge.R              # Consolidação de indicadores IBGE por município
│   └── data/
│       ├── ibge/ibge_indicadores.parquet
│       └── tse/                           # Bases *_clean.parquet
│
└── 03_gold/                               # [Gold] Datamarts, Analytics e Governança
    ├── scripts/
    │   ├── 01_cria_datamart_candidatos.R  # Datamart Candidatos 2024
    │   ├── 02_cria_datamart_municipal.R   # Datamart Municipal 2024
    │   └── 03_join_bases_integracao.R     # Datamart Integrado TSE 2024 + IBGE
    ├── data/                              # Datamarts finais .parquet + metadata.json
    ├── analytics/                         # Gráficos interativos (Plotly & Reactable)
    └── docs/
        └── 01_gera_metadados.R            # Gerador automático do Data Catalog Parquet
```

---

## 🚀 Como Executar

```r
# 1. Instalar dependências (primeira vez)
source("00_instala_pacotes.R")

# 2. Executar toda a esteira ou camadas específicas
source("run_pipeline.R")
executar_pipeline("tudo")     # Bronze -> Silver -> Gold -> Catálogo
executar_pipeline("bronze")   # Apenas ingestão Parquet
executar_pipeline("silver")   # Apenas limpeza Parquet
executar_pipeline("gold")     # Apenas Datamarts finais
executar_pipeline("catalog")  # Apenas dicionário de metadados
```
