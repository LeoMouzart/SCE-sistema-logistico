-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 05_check_nps.sql
--
-- CHECK: NPS / SATISFAÇÃO
--
-- Objetivo:
-- Validar a estrutura e os dados relacionados ao módulo NPS.
-- =========================================================


-- =========================================================
-- VISUALIZAR PESQUISAS NPS
-- =========================================================

SELECT *
FROM pesquisa_nps
ORDER BY created_at DESC;


-- =========================================================
-- VISUALIZAR RESPOSTAS NPS
-- =========================================================

SELECT *
FROM resposta_nps
ORDER BY data_resposta DESC;


-- =========================================================
-- VISUALIZAR NPS CONSOLIDADO POR PEDIDO / VENDEDOR
-- =========================================================

SELECT *
FROM vw_nps_vendedor
ORDER BY data_resposta DESC;


-- =========================================================
-- RESUMO DE NPS POR VENDEDOR
-- =========================================================

SELECT
    id_vendedor,
    vendedor,

    COUNT(*) AS total_respostas,

    ROUND(
        AVG(nota),
        2
    ) AS media_nota,

    COUNT(*) FILTER (
        WHERE classificacao_nps = 'PROMOTOR'
    ) AS promotores,

    COUNT(*) FILTER (
        WHERE classificacao_nps = 'NEUTRO'
    ) AS neutros,

    COUNT(*) FILTER (
        WHERE classificacao_nps = 'DETRATOR'
    ) AS detratores

FROM vw_nps_vendedor

GROUP BY
    id_vendedor,
    vendedor

ORDER BY vendedor;
