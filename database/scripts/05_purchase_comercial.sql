-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 05_purchase_commercial.sql
--
-- MÓDULO: COMERCIAL / COMPRAS
--
-- Objetivo:
-- Registrar o processo comercial de aquisição de materiais
-- antes do recebimento físico da mercadoria.
--
-- Este módulo controla:
-- - promotores comerciais das fábricas;
-- - negociações de preço por m²;
-- - descontos negociados;
-- - frete previsto / negociado;
-- - solicitações de material;
-- - pedidos de compra junto às fábricas;
-- - programação de disponibilidade e coleta.
--
-- Fluxo esperado:
--
-- NECESSIDADE DE MATERIAL
--        ↓
-- SOLICITAÇÃO
--        ↓
-- PROMOTOR / NEGOCIAÇÃO
--        ↓
-- PEDIDO DE COMPRA
--        ↓
-- MATERIAL DISPONÍVEL NA FÁBRICA
--        ↓
-- COLETA PROGRAMADA
--        ↓
-- RECEBIMENTO
--
-- O recebimento físico será tratado posteriormente
-- no módulo de logística de entrada.
-- =========================================================



-- =========================================================
-- PROMOTOR COMERCIAL
--
-- Finalidade:
-- Cadastrar os promotores responsáveis pela negociação
-- comercial diretamente com as fábricas.
--
-- O promotor é o contato responsável por informar:
-- - preço por m²;
-- - descontos;
-- - disponibilidade;
-- - condições comerciais;
-- - frete estimado;
-- - previsão de liberação do material.
-- =========================================================

CREATE TABLE promotor (
    id_promotor BIGSERIAL PRIMARY KEY,

    id_fabricante BIGINT NOT NULL,

    nome VARCHAR(150) NOT NULL,
    telefone VARCHAR(30),
    email VARCHAR(150),

    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_promotor_fabricante
        FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante)
);



-- =========================================================
-- NEGOCIAÇÃO COMERCIAL COM PROMOTOR
--
-- Finalidade:
-- Registrar cada negociação realizada com o promotor,
-- mantendo histórico de preços e condições comerciais.
--
-- Permite registrar:
-- - produto negociado;
-- - valor de tabela;
-- - valor negociado por m²;
-- - percentual de desconto;
-- - frete estimado;
-- - validade da negociação;
-- - observações comerciais.
--
-- O histórico será útil para relatórios de:
-- - preço médio;
-- - evolução de preço;
-- - descontos;
-- - economia negociada;
-- - negociação por fabricante/promotor.
-- =========================================================

CREATE TABLE negociacao_promotor (
    id_negociacao BIGSERIAL PRIMARY KEY,

    id_promotor BIGINT NOT NULL,
    id_produto BIGINT NOT NULL,

    valor_tabela_m2 NUMERIC(12,2),
    valor_negociado_m2 NUMERIC(12,2) NOT NULL,

    percentual_desconto NUMERIC(5,2),

    data_negociacao DATE NOT NULL DEFAULT CURRENT_DATE,
    validade_ate DATE,

    observacao TEXT,

    registrado_por BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_negociacao_promotor
        FOREIGN KEY (id_promotor)
        REFERENCES promotor(id_promotor),

    CONSTRAINT fk_negociacao_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT fk_negociacao_usuario
        FOREIGN KEY (registrado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_negociacao_valor_tabela
        CHECK (
            valor_tabela_m2 IS NULL
            OR valor_tabela_m2 >= 0
        ),

    CONSTRAINT chk_negociacao_valor_negociado
        CHECK (
            valor_negociado_m2 >= 0
        ),

    CONSTRAINT chk_negociacao_desconto
        CHECK (
            percentual_desconto IS NULL
            OR (
                percentual_desconto >= 0
                AND percentual_desconto <= 100
            )
        ),

    CONSTRAINT chk_negociacao_validade
        CHECK (
            validade_ate IS NULL
            OR validade_ate >= data_negociacao
        )
);



-- =========================================================
-- SOLICITAÇÃO DE MATERIAL
--
-- Finalidade:
-- Registrar uma necessidade de aquisição de material.
--
-- A solicitação pode surgir por:
-- - falta de material para um pedido de cliente;
-- - necessidade de reposição de estoque.
--
-- Quando relacionada a uma venda, pode ser vinculada
-- diretamente ao pedido correspondente.
--
-- O status permite acompanhar o processo comercial
-- até que um pedido de compra seja gerado.
-- =========================================================

CREATE TABLE solicitacao_material (
    id_solicitacao BIGSERIAL PRIMARY KEY,

    tipo_solicitacao VARCHAR(30) NOT NULL,

    id_pedido BIGINT,

    solicitado_por BIGINT NOT NULL,

    data_solicitacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status VARCHAR(30) NOT NULL DEFAULT 'ABERTA',

    observacao TEXT,

    CONSTRAINT fk_solicitacao_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_solicitacao_usuario
        FOREIGN KEY (solicitado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_solicitacao_tipo
        CHECK (
            tipo_solicitacao IN (
                'PEDIDO_CLIENTE',
                'REPOSICAO_ESTOQUE'
            )
        ),

    CONSTRAINT chk_solicitacao_status
        CHECK (
            status IN (
                'ABERTA',
                'EM_NEGOCIACAO',
                'APROVADA',
                'PEDIDO_GERADO',
                'CONCLUIDA'
            )
        )
);



-- =========================================================
-- ITENS DA SOLICITAÇÃO DE MATERIAL
--
-- Finalidade:
-- Registrar quais produtos e quantidades fazem parte
-- de cada solicitação de material.
--
-- Permite comparar:
-- - quantidade solicitada;
-- - quantidade aprovada;
-- - necessidade real de compra.
-- =========================================================

CREATE TABLE solicitacao_material_item (
    id_solicitacao_item BIGSERIAL PRIMARY KEY,

    id_solicitacao BIGINT NOT NULL,
    id_produto BIGINT NOT NULL,

    quantidade_solicitada NUMERIC(12,3) NOT NULL,
    quantidade_aprovada NUMERIC(12,3),

    observacao TEXT,

    CONSTRAINT fk_solicitacao_item_solicitacao
        FOREIGN KEY (id_solicitacao)
        REFERENCES solicitacao_material(id_solicitacao),

    CONSTRAINT fk_solicitacao_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT chk_solicitacao_item_quantidade
        CHECK (
            quantidade_solicitada > 0
        ),

    CONSTRAINT chk_solicitacao_item_aprovada
        CHECK (
            quantidade_aprovada IS NULL
            OR quantidade_aprovada >= 0
        )
);



-- =========================================================
-- PEDIDO DE COMPRA
--
-- Finalidade:
-- Registrar a compra efetivamente realizada junto à fábrica.
--
-- Este registro representa o acordo comercial confirmado,
-- já após negociação com o promotor.
--
-- Permite controlar:
-- - fábrica;
-- - promotor;
-- - negociação utilizada;
-- - número do pedido informado pela fábrica;
-- - data da compra;
-- - previsão de disponibilidade;
-- - previsão de coleta;
-- - valor total;
-- - frete previsto;
-- - situação da compra.
--
-- Importante:
-- Material comprado não significa necessariamente material
-- disponível em estoque. A mercadoria pode permanecer na
-- fábrica aguardando a data ideal de coleta.
-- =========================================================

CREATE TABLE pedido_compra (
    id_pedido_compra BIGSERIAL PRIMARY KEY,

    id_fabricante BIGINT NOT NULL,
    id_promotor BIGINT,
    id_negociacao BIGINT,

    numero_pedido_fabrica VARCHAR(100),

    data_pedido DATE NOT NULL DEFAULT CURRENT_DATE,
    data_prevista_disponibilidade DATE,
    data_prevista_coleta DATE,

    status VARCHAR(30) NOT NULL DEFAULT 'SOLICITADO',

    valor_total NUMERIC(14,2),

    observacao TEXT,

    criado_por BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pedido_compra_fabricante
        FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante),

    CONSTRAINT fk_pedido_compra_promotor
        FOREIGN KEY (id_promotor)
        REFERENCES promotor(id_promotor),

    CONSTRAINT fk_pedido_compra_negociacao
        FOREIGN KEY (id_negociacao)
        REFERENCES negociacao_promotor(id_negociacao),

    CONSTRAINT fk_pedido_compra_usuario
        FOREIGN KEY (criado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_pedido_compra_status
        CHECK (
            status IN (
                'SOLICITADO',
                'CONFIRMADO_FABRICA',
                'DISPONIVEL_COLETA',
                'COLETA_PROGRAMADA',
                'COLETADO',
                'RECEBIDO'
            )
        ),

    CONSTRAINT chk_pedido_compra_valor_total
        CHECK (
            valor_total IS NULL
            OR valor_total >= 0
        )
);


-- =========================================================
-- ITENS DO PEDIDO DE COMPRA
--
-- Finalidade:
-- Registrar os produtos efetivamente comprados da fábrica.
--
-- Cada item pode ser relacionado à solicitação que originou
-- a compra, permitindo rastrear:
--
-- pedido de cliente
--      ↓
-- necessidade de material
--      ↓
-- solicitação
--      ↓
-- compra
--
-- Registra também:
-- - quantidade comprada;
-- - preço negociado por m²/unidade;
-- - valor total do item.
-- =========================================================

CREATE TABLE pedido_compra_item (
    id_pedido_compra_item BIGSERIAL PRIMARY KEY,

    id_pedido_compra BIGINT NOT NULL,
    id_produto BIGINT NOT NULL,

    quantidade NUMERIC(12,3) NOT NULL,

    valor_unitario NUMERIC(12,2),

    valor_total_item NUMERIC(14,2),

    id_solicitacao_item BIGINT,

    observacao TEXT,

    CONSTRAINT fk_compra_item_pedido
        FOREIGN KEY (id_pedido_compra)
        REFERENCES pedido_compra(id_pedido_compra),

    CONSTRAINT fk_compra_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT fk_compra_item_solicitacao
        FOREIGN KEY (id_solicitacao_item)
        REFERENCES solicitacao_material_item(id_solicitacao_item),

    CONSTRAINT chk_compra_item_quantidade
        CHECK (
            quantidade > 0
        ),

    CONSTRAINT chk_compra_item_valor
        CHECK (
            valor_unitario IS NULL
            OR valor_unitario >= 0
        ),

    CONSTRAINT chk_compra_item_total
        CHECK (
            valor_total_item IS NULL
            OR valor_total_item >= 0
        )
);
