# ==============================================================================
# OURO 07a: CONCENTRAÇÃO TERRITORIAL DO VOTO (HHI) NOS 189 MUNS MULTI-ZONA (14 COLUNAS)
# ==============================================================================
# Mede o Índice de Herfindahl-Hirschman (HHI) dos votos por zona eleitoral no 1º turno
# (0 = pulverizado, 1 = concentrado em 1 zona) cruzado com gasto digital vs. militância.

if (file.exists("src/modelagem/_helpers_ouro.R")) {
  source("src/modelagem/_helpers_ouro.R")
} else {
  source("_helpers_ouro.R")
}

message("=== [Ouro 07a] Construindo ouro_concentracao_zonas.parquet ===")

com_conexao_duckdb(function(con) {
  sql <- sprintf("
    WITH muns_multi AS (
      SELECT cd_municipio_tse, COUNT(DISTINCT nr_zona) AS qtd_zonas_municipio
      FROM read_parquet('%s')
      WHERE nr_turno = 1
      GROUP BY 1
      HAVING COUNT(DISTINCT nr_zona) >= 2
    ),
    vot_cand_zona AS (
      SELECT v.sq_candidato, v.cd_municipio_tse, v.nr_zona, SUM(v.qt_votos_nominais) AS votos_zona
      FROM read_parquet('%s') v
      JOIN muns_multi mm ON v.cd_municipio_tse = mm.cd_municipio_tse
      WHERE v.nr_turno = 1 AND v.qt_votos_nominais > 0
      GROUP BY 1, 2, 3
    ),
    hhi_cand AS (
      SELECT
        sq_candidato,
        cd_municipio_tse,
        CAST(COUNT(*) AS INTEGER) AS qtd_zonas_com_voto,
        CAST(SUM(votos_zona) AS INTEGER) AS total_votos_1t,
        SUM(POWER(CAST(votos_zona AS DOUBLE), 2)) / POWER(CAST(SUM(votos_zona) AS DOUBLE), 2) AS hhi_voto_zonas
      FROM vot_cand_zona
      GROUP BY 1, 2
    ),
    desp_perfil AS (
      SELECT
        sq_candidato,
        SUM(vr_despesa_contratada) AS total_gasto,
        SUM(CASE WHEN CONTAINS(UPPER(COALESCE(ds_origem_despesa, '')), 'IMPULSIONAMENTO')
                   OR CONTAINS(UPPER(COALESCE(ds_origem_despesa, '')), 'INTERNET')
                 THEN vr_despesa_contratada ELSE 0.0 END) AS vl_digital,
        SUM(CASE WHEN CONTAINS(UPPER(COALESCE(ds_origem_despesa, '')), 'MILITÂNCIA')
                   OR CONTAINS(UPPER(COALESCE(ds_origem_despesa, '')), 'PESSOAL')
                 THEN vr_despesa_contratada ELSE 0.0 END) AS vl_militancia
      FROM read_parquet('%s')
      GROUP BY 1
    )
    SELECT
      c.sq_candidato,
      m.sg_uf,
      m.regiao,
      m.nm_municipio,
      mm.qtd_zonas_municipio,
      p.sg_partido,
      c.ds_cargo,
      c.is_eleito,
      h.total_votos_1t,
      h.qtd_zonas_com_voto,
      ROUND(h.hhi_voto_zonas, 6) AS hhi_voto_zonas,
      COALESCE(d.total_gasto, 0.0) AS total_gasto,
      CASE WHEN COALESCE(d.total_gasto, 0.0) > 0
           THEN COALESCE(d.vl_digital, 0.0) * 100.0 / d.total_gasto
           ELSE 0.0 END AS pct_gasto_digital,
      CASE WHEN COALESCE(d.total_gasto, 0.0) > 0
           THEN COALESCE(d.vl_militancia, 0.0) * 100.0 / d.total_gasto
           ELSE 0.0 END AS pct_gasto_militancia
    FROM hhi_cand h
    JOIN muns_multi mm ON h.cd_municipio_tse = mm.cd_municipio_tse
    JOIN read_parquet('%s') c ON h.sq_candidato = c.sq_candidato
    JOIN read_parquet('%s') m ON h.cd_municipio_tse = m.cd_municipio_tse
    JOIN read_parquet('%s') p ON c.nr_partido = p.nr_partido
    LEFT JOIN desp_perfil d ON h.sq_candidato = d.sq_candidato
  ",
    prata_sql("fato_votacao.parquet"),
    prata_sql("fato_votacao.parquet"),
    prata_sql("fato_despesas.parquet"),
    prata_sql("dim_candidato.parquet"),
    prata_sql("dim_municipio.parquet"),
    prata_sql("dim_partido.parquet")
  )
  n <- executar_copy_parquet(con, sql, ouro_dest("ouro_concentracao_zonas.parquet"))
  message("✔ dados/ouro/ouro_concentracao_zonas.parquet salvo (", n, " candidaturas multi-zona, 14 colunas)")
})
