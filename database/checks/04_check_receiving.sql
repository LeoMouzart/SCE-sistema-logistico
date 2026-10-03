-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 04_check_receiving.sql
--
-- CHECK: RECEBIMENTO / LOGÍSTICA
--
-- Objetivo:
-- Conferir cargas recebidas, pedidos de compra associados,
-- itens recebidos e informações de frete.
-- =========================================================


-- RECEBIMENTOS

SELECT *
FROM recebimento_carga;


-- PEDIDOS DE COMPRA ASSOCIADOS AO RECEBIMENTO

SELECT *
FROM recebimento_carga_compra;


-- ITENS RECEBIDOS

SELECT *
FROM recebimento_carga_item;


-- VIEW DE FRETE MENSAL

SELECT *
FROM vw_frete_mensal;


-- TOTAL DE FRETE POR MÊS

SELECT
    mes_pagamento,
    SUM(valor_frete_total) AS total_frete_pago
FROM vw_frete_mensal
WHERE data_pagamento_frete IS NOT NULL
GROUP BY mes_pagamento
ORDER BY mes_pagamento;
