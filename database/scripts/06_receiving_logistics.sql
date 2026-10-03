-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 06_receiving_logistics.sql
--
-- MÓDULO: RECEBIMENTO / LOGÍSTICA DE ENTRADA
--
-- Objetivo:
-- Registrar o recebimento físico de cargas vindas das
-- fábricas ou de outras origens, transportadas por terceiros.
--
-- Este módulo controla:
-- - transportadora responsável pela carga;
-- - motorista;
-- - origem do material;
-- - data prevista de chegada;
-- - data e hora real de chegada;
-- - pedidos de compra contidos na carga;
-- - produtos e lotes recebidos;
-- - quantidade e m² recebidos;
-- - frete total pago;
-- - data de pagamento do frete;
-- - rateio opcional do frete por item;
-- - usuário responsável pelo recebimento.
--
-- Fluxo esperado:
--
-- PEDIDO DE COMPRA
--        ↓
-- MATERIAL DISPONÍVEL NA FÁBRICA
--        ↓
-- COLETA PROGRAMADA
--        ↓
-- TRANSPORTADORA / MOTORISTA
--        ↓
-- RECEBIMENTO DA CARGA
--        ↓
-- REGISTRO DOS ITENS RECEBIDOS
--        ↓
-- ENTRADA NO ESTOQUE
--
-- Este módulo também servirá de base para relatórios de:
-- - frete mensal pago;
-- - frete por transportadora;
-- - frete por produto;
-- - frete por m²;
-- - quantidade de cargas recebidas;
-- - quantidade de pedidos por carga;
-- - m² transportados;
-- - atrasos de recebimento.
-- =========================================================



-- =========================================================
-- RECEBIMENTO DE CARGA
--
-- Finalidade:
-- Representar cada chegada física de uma carga à empresa.
--
-- Uma carga pode conter vários pedidos de compra e vários
-- produtos.
--
-- Os campos quantidade_pedidos_informada e
-- total_m2_informado representam os valores registrados
-- no momento do recebimento.
--
-- O valor_frete_total representa o valor total cobrado
-- pela transportadora para aquela carga.
--
-- A data_pagamento_frete permite gerar relatórios com base
-- no mês em que o frete foi efetivamente pago.
-- =========================================================

CREATE TABLE recebimento_carga (
    id_recebimento BIGSERIAL PRIMARY KEY,

    id_transportadora BIGINT NOT NULL,
    id_motorista BIGINT,
    id_origem BIGINT NOT NULL,

    data_prevista DATE,

    data_chegada DATE NOT NULL,
    hora_chegada TIME,

    quantidade_pedidos_informada INTEGER NOT NULL DEFAULT 0,
    total_m2_informado NUMERIC(12,3) NOT NULL DEFAULT 0,

    valor_frete_total NUMERIC(12,2),

    data_pagamento_frete DATE,

    observacao TEXT,

    recebido_por BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_recebimento_transportadora
        FOREIGN KEY (id_transportadora)
        REFERENCES transportadora(id_transportadora),

    CONSTRAINT fk_recebimento_motorista
        FOREIGN KEY (id_motorista)
        REFERENCES motorista(id_motorista),

    CONSTRAINT fk_recebimento_origem
        FOREIGN KEY (id_origem)
        REFERENCES origem_material(id_origem),

    CONSTRAINT fk_recebimento_usuario
        FOREIGN KEY (recebido_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_recebimento_quantidade_pedidos
        CHECK (
            quantidade_pedidos_informada >= 0
        ),

    CONSTRAINT chk_recebimento_total_m2
        CHECK (
            total_m2_informado >= 0
        ),

    CONSTRAINT chk_recebimento_frete
        CHECK (
            valor_frete_total IS NULL
            OR valor_frete_total >= 0
        )
);



-- =========================================================
-- PEDIDOS DE COMPRA CONTIDOS NA CARGA
--
-- Finalidade:
-- Relacionar cada carga recebida aos pedidos de compra que
-- foram transportados nela.
--
-- Isso permite saber:
-- - quais pedidos vieram em determinada carga;
-- - quantos pedidos cada transportadora trouxe;
-- - quais pedidos de compra já foram recebidos;
-- - quais pedidos ainda aguardam chegada.
--
-- Uma mesma carga pode conter vários pedidos de compra.
-- =========================================================

CREATE TABLE recebimento_carga_compra (
    id_recebimento_compra BIGSERIAL PRIMARY KEY,

    id_recebimento BIGINT NOT NULL,
    id_pedido_compra BIGINT NOT NULL,

    CONSTRAINT fk_recebimento_compra_recebimento
        FOREIGN KEY (id_recebimento)
        REFERENCES recebimento_carga(id_recebimento),

    CONSTRAINT fk_recebimento_compra_pedido
        FOREIGN KEY (id_pedido_compra)
        REFERENCES pedido_compra(id_pedido_compra),

    CONSTRAINT uq_recebimento_compra
        UNIQUE (
            id_recebimento,
            id_pedido_compra
        )
);



-- =========================================================
-- ITENS RECEBIDOS NA CARGA
--
-- Finalidade:
-- Registrar os produtos e lotes que efetivamente chegaram
-- em cada carga.
--
-- Permite controlar:
-- - produto recebido;
-- - lote;
-- - quantidade;
-- - quantidade em m²;
-- - valor do frete rateado para aquele item.
--
-- O valor_frete_rateado é opcional.
-- Futuramente o sistema poderá ratear automaticamente
-- o valor total do frete por m², quantidade ou manualmente.
-- =========================================================

CREATE TABLE recebimento_carga_item (
    id_recebimento_item BIGSERIAL PRIMARY KEY,

    id_recebimento BIGINT NOT NULL,

    id_produto BIGINT NOT NULL,
    id_lote BIGINT,

    quantidade NUMERIC(12,3) NOT NULL,
    quantidade_m2 NUMERIC(12,3),

    valor_frete_rateado NUMERIC(12,2),

    observacao TEXT,

    CONSTRAINT fk_recebimento_item_recebimento
        FOREIGN KEY (id_recebimento)
        REFERENCES recebimento_carga(id_recebimento),

    CONSTRAINT fk_recebimento_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT fk_recebimento_item_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote(id_lote),

    CONSTRAINT chk_recebimento_item_quantidade
        CHECK (
            quantidade > 0
        ),

    CONSTRAINT chk_recebimento_item_m2
        CHECK (
            quantidade_m2 IS NULL
            OR quantidade_m2 >= 0
        ),

    CONSTRAINT chk_recebimento_item_frete
        CHECK (
            valor_frete_rateado IS NULL
            OR valor_frete_rateado >= 0
        )
);
