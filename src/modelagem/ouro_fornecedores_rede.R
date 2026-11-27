# ==============================================================================
# OURO 07b: REDE E CONCENTRAÇÃO DE FORNECEDORES ELEITORAIS (12 COLUNAS)
# ==============================================================================
# Grão: fornecedor (nr_cpf_cnpj_fornecedor com >= 2 candidatos atendidos).
# Mede alcance intermunicipal/interestadual, capilaridade partidária e setor CNAE.

if (file.exists("src/modelagem/_helpers_ouro.R")) {
  source("src/modelagem/_helpers_ouro.R")
} else {
  source("_helpers_ouro.R")
}

message("=== [Ouro 07b] Construindo ouro_fornecedores_rede.parquet ===")

com_conexao_duckdb(function(con) {
  sql <- sprintf("
    WITH desp_enr AS (
      SELECT
        d.nr_cpf_cnpj_fornecedor,
        d.nm_fornecedor,
        d.ds_cnae_fornecedor,
        %s AS macro_categoria,
        d.sq_candidato,
        d.cd_municipio_tse,
        m.sg_uf,
        c.nr_partido,
        d.vr_despesa_contratada
      FROM read_parquet('%s') d
      JOIN read_parquet('%s') c ON d.sq_candidato = c.sq_candidato
      JOIN read_parquet('%s') m ON c.cd_municipio_tse = m.cd_municipio_tse
      WHERE d.nr_cpf_cnpj_fornecedor IS NOT NULL
    ),
    top_nome AS (
      SELECT nr_cpf_cnpj_fornecedor, nm_fornecedor
      FROM (
        SELECT nr_cpf_cnpj_fornecedor, nm_fornecedor, SUM(vr_despesa_contratada) AS v
        FROM desp_enr
        WHERE nm_fornecedor IS NOT NULL
        GROUP BY 1, 2
      )
      QUALIFY ROW_NUMBER() OVER (PARTITION BY nr_cpf_cnpj_fornecedor ORDER BY v DESC) = 1
    ),
    top_cnae AS (
      SELECT nr_cpf_cnpj_fornecedor, ds_cnae_fornecedor
      FROM (
        SELECT nr_cpf_cnpj_fornecedor, ds_cnae_fornecedor, SUM(vr_despesa_contratada) AS v
        FROM desp_enr
        WHERE ds_cnae_fornecedor IS NOT NULL
        GROUP BY 1, 2
      )
      QUALIFY ROW_NUMBER() OVER (PARTITION BY nr_cpf_cnpj_fornecedor ORDER BY v DESC) = 1
    ),
    top_cat AS (
      SELECT nr_cpf_cnpj_fornecedor, macro_categoria
      FROM (
        SELECT nr_cpf_cnpj_fornecedor, macro_categoria, SUM(vr_despesa_contratada) AS v
        FROM desp_enr
        GROUP BY 1, 2
      )
      QUALIFY ROW_NUMBER() OVER (PARTITION BY nr_cpf_cnpj_fornecedor ORDER BY v DESC) = 1
    ),
    agg_forn AS (
      SELECT
        nr_cpf_cnpj_fornecedor,
        CAST(COUNT(*) AS INTEGER) AS qtd_lancamentos,
        CAST(COUNT(DISTINCT sq_candidato) AS INTEGER) AS qtd_candidatos,
        CAST(COUNT(DISTINCT cd_municipio_tse) AS INTEGER) AS qtd_municipios,
        CAST(COUNT(DISTINCT sg_uf) AS INTEGER) AS qtd_ufs,
        CAST(COUNT(DISTINCT nr_partido) AS INTEGER) AS qtd_partidos,
        SUM(vr_despesa_contratada) AS valor_total_contratado,
        AVG(vr_despesa_contratada) AS ticket_medio
      FROM desp_enr
      GROUP BY 1
      HAVING COUNT(DISTINCT sq_candidato) >= 2
    )
    SELECT
      a.nr_cpf_cnpj_fornecedor,
      n.nm_fornecedor,
      cn.ds_cnae_fornecedor,
      ct.macro_categoria AS macro_categoria_principal,
      a.qtd_lancamentos,
      a.qtd_candidatos,
      a.qtd_municipios,
      a.qtd_ufs,
      a.qtd_partidos,
      a.valor_total_contratado,
      a.ticket_medio,
      (a.qtd_municipios >= 10) AS flag_rede_multi_municipio
    FROM agg_forn a
    LEFT JOIN top_nome n ON a.nr_cpf_cnpj_fornecedor = n.nr_cpf_cnpj_fornecedor
    LEFT JOIN top_cnae cn ON a.nr_cpf_cnpj_fornecedor = cn.nr_cpf_cnpj_fornecedor
    LEFT JOIN top_cat ct ON a.nr_cpf_cnpj_fornecedor = ct.nr_cpf_cnpj_fornecedor
  ",
    sql_macro_categoria_despesa("d.ds_origem_despesa"),
    prata_sql("fato_despesas.parquet"),
    prata_sql("dim_candidato.parquet"),
    prata_sql("dim_municipio.parquet")
  )
  n <- executar_copy_parquet(con, sql, ouro_dest("ouro_fornecedores_rede.parquet"))
  message("✔ dados/ouro/ouro_fornecedores_rede.parquet salvo (", n, " fornecedores, 12 colunas)")
})
