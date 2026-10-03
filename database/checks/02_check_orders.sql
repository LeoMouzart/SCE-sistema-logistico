-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 02_check_orders.sql
--
-- CHECK: PEDIDOS
--
-- Objetivo:
-- Conferir pedidos, itens, históricos, alterações de prazo
-- e solicitações de entrega parcial.
-- =========================================================


-- PEDIDOS

SELECT *
FROM pedido;


-- ITENS DOS PEDIDOS

SELECT *
FROM pedido_item;


-- HISTÓRICO DE STATUS DOS PEDIDOS

SELECT *
FROM pedido_status_historico;


-- ALTERAÇÕES DE PRAZO

SELECT *
FROM pedido_alteracao_prazo;


-- SOLICITAÇÕES DE ENTREGA PARCIAL

SELECT *
FROM solicitacao_entrega_parcial;


-- VIEW DE CONTROLE DE PRAZOS

SELECT *
FROM vw_pedidos_prazo;
