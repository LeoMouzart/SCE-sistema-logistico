-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 04_vw_frete_mensal.sql
--
-- VIEW: FRETE MENSAL
--
-- Objetivo:
-- Consolidar informações dos fretes de recebimento para
-- relatórios financeiros e logísticos.
--
-- Esta view permite analisar:
-- - transportadora;
-- - data de chegada;
-- - data de pagamento do frete;
-- - valor total do frete;
-- - total de m² informado;
-- - valor médio do frete por m²;
-- - mês de pagamento.
--
-- Regra:
-- O relatório mensal deve considerar preferencialmente
-- a data de pagamento do frete, e não a data de chegada.
-- =========================================================


CREATE OR REPLACE VIEW vw_frete_mensal AS

SELECT
    rc.id_recebimento,

    rc.id_transportadora,
    t.nome_fantasia AS transportadora,

    rc.data_chegada,
    rc.data_pagamento_frete,

    DATE_TRUNC(
        'month',
        rc.data_pagamento_frete
    )::DATE AS mes_pagamento,

    rc.total_m2_informado,

    rc.valor_frete_total,

    CASE
        WHEN rc.valor_frete_total IS NULL
            THEN NULL

        WHEN rc.total_m2_informado IS NULL
             OR rc.total_m2_informado = 0
            THEN NULL

        ELSE ROUND(
            rc.valor_frete_total
            / rc.total_m2_informado,
            2
        )
    END AS valor_frete_m2

FROM recebimento_carga rc

JOIN transportadora t
    ON t.id_transportadora = rc.id_transportadora;
