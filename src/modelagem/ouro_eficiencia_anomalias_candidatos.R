# ==============================================================================
# OURO 03: EFICIÊNCIA, ANOMALIAS, DOBRADINHAS E MIGRAÇÃO POLÍTICA (20 COLUNAS)
# ==============================================================================
# Grão: candidato (463.731 registros). Permite detectar candidaturas com alto
# recurso e baixa votação, efeito dobradinha e votos anulados sub judice.

if (file.exists("src/modelagem/_helpers_ouro.R")) {
  source("src/modelagem/_helpers_ouro.R")
} else {
  source("_helpers_ouro.R")
}

message("=== [Ouro 03] Construindo ouro_eficiencia_anomalias_candidatos.parquet ===")

com_conexao_duckdb(function(con) {
  sql <- sprintf("
    WITH vot_agg AS (
      SELECT
        sq_candidato,
        CAST(SUM(qt_votos_nominais) AS INTEGER) AS total_votos,
        CAST(SUM(qt_votos_nominais_validos) AS INTEGER) AS total_votos_validos,
        CAST(GREATEST(SUM(qt_votos_nominais) - SUM(qt_votos_nominais_validos), 0) AS INTEGER) AS votos_anulados_subjudice
      FROM read_parquet('%s')
      GROUP BY 1
    ),
    rec_agg AS (
      SELECT
        sq_candidato,
        SUM(vr_receita) AS total_arrecadado,
        SUM(CASE WHEN is_fundo_publico THEN vr_receita ELSE 0.0 END) AS total_fundo_publico,
        SUM(CASE WHEN sq_candidato_doador IS NOT NULL THEN vr_receita ELSE 0.0 END) AS vl_dobradinha
      FROM read_parquet('%s')
      GROUP BY 1
    ),
    desp_agg AS (
      SELECT sq_candidato, SUM(vr_despesa_contratada) AS total_gasto
      FROM read_parquet('%s')
      GROUP BY 1
    )
    SELECT
      c.sq_candidato,
      m.sg_uf,
      m.regiao,
      m.porte_municipio,
      p.sg_partido,
      c.ds_cargo,
      c.ds_genero,
      c.ds_cor_raca,
      c.idade_2024,
      c.is_candidato_local,
      c.disputou_segundo_turno,
      c.is_eleito,
      COALESCE(v.total_votos, 0) AS total_votos,
      COALESCE(v.votos_anulados_subjudice, 0) AS votos_anulados_subjudice,
      COALESCE(r.total_arrecadado, 0.0) AS total_arrecadado,
      COALESCE(r.total_fundo_publico, 0.0) AS total_fundo_publico,
      COALESCE(d.total_gasto, 0.0) AS total_gasto,
      CASE WHEN COALESCE(r.total_arrecadado, 0.0) > 0
           THEN (COALESCE(r.vl_dobradinha, 0.0) * 100.0) / r.total_arrecadado
           ELSE 0.0 END AS pct_receita_de_outros_candidatos,
      CASE WHEN COALESCE(v.total_votos, 0) > 0
           THEN COALESCE(d.total_gasto, 0.0) / v.total_votos
           ELSE NULL END AS custo_por_voto,
      (COALESCE(v.total_votos, 0) <= 10 AND COALESCE(r.total_arrecadado, 0.0) >= 10000.0) AS flag_anomalia_voto_recurso
    FROM read_parquet('%s') c
    JOIN read_parquet('%s') m ON c.cd_municipio_tse = m.cd_municipio_tse
    JOIN read_parquet('%s') p ON c.nr_partido = p.nr_partido
    LEFT JOIN vot_agg v ON c.sq_candidato = v.sq_candidato
    LEFT JOIN rec_agg r ON c.sq_candidato = r.sq_candidato
    LEFT JOIN desp_agg d ON c.sq_candidato = d.sq_candidato
  ",
    prata_sql("fato_votacao.parquet"),
    prata_sql("fato_receitas.parquet"),
    prata_sql("fato_despesas.parquet"),
    prata_sql("dim_candidato.parquet"),
    prata_sql("dim_municipio.parquet"),
    prata_sql("dim_partido.parquet")
  )
  n <- executar_copy_parquet(con, sql, ouro_dest("ouro_eficiencia_anomalias_candidatos.parquet"))
  message("✔ dados/ouro/ouro_eficiencia_anomalias_candidatos.parquet salvo (", n, " candidatos, 20 colunas)")
})
