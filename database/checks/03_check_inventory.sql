-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 03_check_inventory.sql
--
-- CHECK: ESTOQUE / INVENTÁRIO
--
-- Objetivo:
-- Conferir saldo, movimentações, reservas e inventários.
-- =========================================================


-- SALDO ATUAL

SELECT *
FROM estoque_saldo;


-- MOVIMENTAÇÕES DE ESTOQUE

SELECT *
FROM movimentacao_estoque;


-- RESERVAS

SELECT *
FROM reserva_estoque;


-- INVENTÁRIOS

SELECT *
FROM inventario_estoque;


-- ITENS DOS INVENTÁRIOS

SELECT *
FROM inventario_item;


-- VIEW DE ESTOQUE DISPONÍVEL

SELECT *
FROM vw_estoque_disponivel;


-- VIEW DE DIVERGÊNCIA DE INVENTÁRIO

SELECT *
FROM vw_divergencia_inventario;
