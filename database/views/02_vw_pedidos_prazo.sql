-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 02_vw_pedidos_prazo.sql
--
-- VIEW: CONTROLE DE PRAZO DOS PEDIDOS
--
-- Objetivo:
-- Consolidar informações de prazo dos pedidos para uso em
-- telas operacionais, relatórios, alertas e dashboards.
--
-- Situações calculadas:
-- - ENTREGUE
-- - ATRASADO
-- - ENTREGA_HOJE
-- - PROXIMO_PRAZO
-- - NO_PRAZO
--
-- Regra inicial:
-- Considerar como próximo do prazo pedidos com até 3 dias
-- restantes para a data prevista de entrega.
-- =========================================================


CREATE OR REPLACE VIEW vw_pedidos_prazo AS

SELECT
    p.id_pedido,
    p.numero_linx,

    p.id_cliente,
    c.nome_razao_social AS cliente,

    p.id_vendedor,
    v.nome AS vendedor,

    p.data_venda,

    p.data_entrega_original,
    p.data_entrega_prevista,

    p.status_atual,

    p.nf_emitida,
    p.numero_nf,
    p.data_emissao_nf,

    CASE
        WHEN p.data_entrega_prevista IS NOT NULL
            THEN p.data_entrega_prevista - CURRENT_DATE
        ELSE NULL
    END AS dias_para_entrega,

    CASE

        WHEN p.status_atual = 'ENTREGUE'
            THEN 'ENTREGUE'

        WHEN p.data_entrega_prevista IS NULL
            THEN 'SEM_PREVISAO'

        WHEN p.data_entrega_prevista < CURRENT_DATE
            THEN 'ATRASADO'

        WHEN p.data_entrega_prevista = CURRENT_DATE
            THEN 'ENTREGA_HOJE'

        WHEN p.data_entrega_prevista > CURRENT_DATE
             AND p.data_entrega_prevista - CURRENT_DATE <= 3
            THEN 'PROXIMO_PRAZO'

        ELSE 'NO_PRAZO'

    END AS situacao_prazo

FROM pedido p

JOIN cliente c
    ON c.id_cliente = p.id_cliente

JOIN vendedor v
    ON v.id_vendedor = p.id_vendedor;
