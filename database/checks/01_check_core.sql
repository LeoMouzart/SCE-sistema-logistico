-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 01_check_core.sql
--
-- CHECK: ESTRUTURA PRINCIPAL / CORE
--
-- Objetivo:
-- Conferir os principais cadastros estruturais do sistema.
-- =========================================================


-- CLIENTES

SELECT *
FROM cliente
ORDER BY id_cliente;


-- VENDEDORES

SELECT *
FROM vendedor
ORDER BY id_vendedor;


-- CATEGORIAS

SELECT *
FROM categoria
ORDER BY id_categoria;


-- FABRICANTES

SELECT *
FROM fabricante
ORDER BY id_fabricante;


-- PRODUTOS

SELECT *
FROM produto
ORDER BY id_produto;


-- LOTES

SELECT *
FROM lote
ORDER BY id_lote;


-- ORIGENS DE MATERIAL

SELECT *
FROM origem_material
ORDER BY id_origem;


-- TRANSPORTADORAS

SELECT *
FROM transportadora
ORDER BY id_transportadora;


-- MOTORISTAS

SELECT *
FROM motorista
ORDER BY id_motorista;


-- USUÁRIOS

SELECT *
FROM usuario
ORDER BY id_usuario;


-- LOCAIS DE ESTOQUE

SELECT *
FROM local_estoque
ORDER BY id_local;


-- CLASSIFICAÇÕES DE ESTOQUE

SELECT *
FROM classificacao_estoque
ORDER BY id_classificacao;
