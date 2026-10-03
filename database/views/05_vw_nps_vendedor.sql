-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 05_vw_nps_vendedor.sql
--
-- VIEW: NPS POR VENDEDOR
--
-- Objetivo:
-- Consolidar os feedbacks de satisfação dos clientes,
-- relacionando cada resposta NPS ao pedido e ao vendedor
-- responsável pela venda.
--
-- Esta view permite analisar:
-- - pedido avaliado;
-- - cliente;
-- - vendedor;
-- - respondente;
-- - nota NPS;
-- - classificação NPS;
-- - comentário;
-- - canal da resposta;
-- - data da resposta.
--
-- Classificação:
-- 0 a 6  = DETRATOR
-- 7 a 8  = NEUTRO
-- 9 a 10 = PROMOTOR
-- =========================================================


CREATE OR REPLACE VIEW vw_nps_vendedor AS

SELECT
    rn.id_resposta,

    pn.id_pesquisa,

    p.id_pedido,
    p.numero_linx,

    c.id_cliente,
    c.nome_razao_social AS cliente,

    v.id_vendedor,
    v.nome AS vendedor,

    rn.nome_respondente,
    rn.email_respondente,
    rn.telefone_respondente,

    rn.canal_resposta,

    rn.nota,

    CASE
        WHEN rn.nota BETWEEN 0 AND 6
            THEN 'DETRATOR'

        WHEN rn.nota BETWEEN 7 AND 8
            THEN 'NEUTRO'

        WHEN rn.nota BETWEEN 9 AND 10
            THEN 'PROMOTOR'
    END AS classificacao_nps,

    rn.comentario,

    rn.data_resposta

FROM resposta_nps rn

JOIN pesquisa_nps pn
    ON pn.id_pesquisa = rn.id_pesquisa

JOIN pedido p
    ON p.id_pedido = pn.id_pedido

JOIN cliente c
    ON c.id_cliente = p.id_cliente

JOIN vendedor v
    ON v.id_vendedor = p.id_vendedor;
