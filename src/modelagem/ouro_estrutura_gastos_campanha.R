# ==============================================================================
# OURO 05: ESTRUTURA DE GASTOS DE CAMPANHA (DIGITAL VS TRADICIONAL - 10 COLUNAS)
# ==============================================================================
# Agrega despesas por UF, região, porte municipal, cargo, status eleito,
# turno, semana e 7 macro-categorias funcionais de gasto.

if (file.exists("src/modelagem/_helpers_ouro.R")) {
  source("src/modelagem/_helpers_ouro.R")
} else {
  source("_helpers_ouro.R")
}

message("=== [Ouro 05] Construindo ouro_estrutura_gastos_campanha.parquet ===")

com_conexao_duckdb(function(con) {
  sql <- sprintf("
    SELECT
      m.sg_uf,
      m.regiao,
      m.porte_municipio,
      c.ds_cargo,
      c.is_eleito,
      d.st_turno,
      DATE_TRUNC('week', d.dt_despesa)::DATE AS semana_eleicao,
      %s AS macro_categoria_despesa,
      CAST(COUNT(*) AS INTEGER) AS qtd_lancamentos,
      SUM(d.vr_despesa_contratada) AS total_despesa
    FROM read_parquet('%s') d
    JOIN read_parquet('%s') c ON d.sq_candidato = c.sq_candidato
    JOIN read_parquet('%s') m ON c.cd_municipio_tse = m.cd_municipio_tse
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
  ",
    sql_macro_categoria_despesa("d.ds_origem_despesa"),
    prata_sql("fato_despesas.parquet"),
    prata_sql("dim_candidato.parquet"),
    prata_sql("dim_municipio.parquet")
  )
  n <- executar_copy_parquet(con, sql, ouro_dest("ouro_estrutura_gastos_campanha.parquet"))
  message("✔ dados/ouro/ouro_estrutura_gastos_campanha.parquet salvo (", n, " linhas agregadas, 10 colunas)")
})
