-- =========================================================
-- HISTÓRICO DE MOVIMENTAÇÃO DE ESTOQUE
-- =========================================================

CREATE TABLE movimentacao_estoque (
    id_movimentacao BIGSERIAL PRIMARY KEY,

    id_produto BIGINT NOT NULL,
    id_lote BIGINT,

    id_local_origem BIGINT,
    id_local_destino BIGINT,

    id_classificacao_origem BIGINT,
    id_classificacao_destino BIGINT,

    tipo_movimentacao VARCHAR(40) NOT NULL,

    quantidade NUMERIC(12,3) NOT NULL,

    id_pedido BIGINT,
    id_usuario BIGINT NOT NULL,

    observacao TEXT,

    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_mov_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT fk_mov_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote(id_lote),

    CONSTRAINT fk_mov_local_origem
        FOREIGN KEY (id_local_origem)
        REFERENCES local_estoque(id_local),

    CONSTRAINT fk_mov_local_destino
        FOREIGN KEY (id_local_destino)
        REFERENCES local_estoque(id_local),

    CONSTRAINT fk_mov_classificacao_origem
        FOREIGN KEY (id_classificacao_origem)
        REFERENCES classificacao_estoque(id_classificacao),

    CONSTRAINT fk_mov_classificacao_destino
        FOREIGN KEY (id_classificacao_destino)
        REFERENCES classificacao_estoque(id_classificacao),

    CONSTRAINT fk_mov_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_mov_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_mov_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT chk_mov_tipo
        CHECK (
            tipo_movimentacao IN (
         'ENTRADA',
            'RESERVA',
            'LIBERACAO_RESERVA',
            'SEPARACAO',
            'ENTREGA',
            'DEVOLUCAO',
            'BAIXA_MANUAL',
            'AJUSTE_INVENTARIO'
            )
        )
);


-- =========================================================
-- SALDO ATUAL DO ESTOQUE
-- =========================================================

CREATE TABLE estoque_saldo (
    id_estoque BIGSERIAL PRIMARY KEY,

    id_produto BIGINT NOT NULL,
    id_lote BIGINT,
    id_local BIGINT NOT NULL,
    id_classificacao BIGINT NOT NULL,

    quantidade NUMERIC(12,3) NOT NULL DEFAULT 0,

    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_estoque_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT fk_estoque_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote(id_lote),

    CONSTRAINT fk_estoque_local
        FOREIGN KEY (id_local)
        REFERENCES local_estoque(id_local),

    CONSTRAINT fk_estoque_classificacao
        FOREIGN KEY (id_classificacao)
        REFERENCES classificacao_estoque(id_classificacao),

    CONSTRAINT chk_estoque_quantidade
        CHECK (quantidade >= 0)
);


-- =========================================================
-- RESERVA DE ESTOQUE POR PEDIDO
-- =========================================================

CREATE TABLE reserva_estoque (
    id_reserva BIGSERIAL PRIMARY KEY,

    id_pedido BIGINT NOT NULL,
    id_pedido_item BIGINT NOT NULL,

    id_produto BIGINT NOT NULL,
    id_lote BIGINT,

    id_local BIGINT NOT NULL,
    id_classificacao BIGINT NOT NULL,

    quantidade_reservada NUMERIC(12,3) NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'ATIVA',

    reservado_por BIGINT NOT NULL,
    reservado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    liberado_em TIMESTAMP,

    observacao TEXT,

    CONSTRAINT fk_reserva_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_reserva_item
        FOREIGN KEY (id_pedido_item)
        REFERENCES pedido_item(id_pedido_item),

    CONSTRAINT fk_reserva_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT fk_reserva_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote(id_lote),

    CONSTRAINT fk_reserva_local
        FOREIGN KEY (id_local)
        REFERENCES local_estoque(id_local),

    CONSTRAINT fk_reserva_classificacao
        FOREIGN KEY (id_classificacao)
        REFERENCES classificacao_estoque(id_classificacao),

    CONSTRAINT fk_reserva_usuario
        FOREIGN KEY (reservado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_reserva_quantidade
        CHECK (quantidade_reservada > 0),

    CONSTRAINT chk_reserva_status
        CHECK (
            status IN (
                'ATIVA',
                'PARCIAL',
                'LIBERADA',
                'CONSUMIDA'
            )
        )
);


-- =========================================================
-- INVENTÁRIO / CONTAGEM DE ESTOQUE
-- =========================================================

CREATE TABLE inventario_estoque (
    id_inventario BIGSERIAL PRIMARY KEY,

    data_contagem DATE NOT NULL,
    id_local BIGINT NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'ABERTO',

    iniciado_por BIGINT NOT NULL,
    conferido_por BIGINT,

    observacao TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finalizado_at TIMESTAMP,

    CONSTRAINT fk_inventario_local
        FOREIGN KEY (id_local)
        REFERENCES local_estoque(id_local),

    CONSTRAINT fk_inventario_usuario_inicio
        FOREIGN KEY (iniciado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT fk_inventario_usuario_conferencia
        FOREIGN KEY (conferido_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_inventario_status
        CHECK (
            status IN (
                'ABERTO',
                'EM_CONTAGEM',
                'CONFERIDO',
                'FINALIZADO'
            )
        )
);


-- =========================================================
-- ITENS DO INVENTÁRIO
-- =========================================================

CREATE TABLE inventario_item (
    id_inventario_item BIGSERIAL PRIMARY KEY,

    id_inventario BIGINT NOT NULL,

    id_produto BIGINT NOT NULL,
    id_lote BIGINT,

    id_classificacao BIGINT NOT NULL,

    quantidade_sistema NUMERIC(12,3) NOT NULL,
    quantidade_contada NUMERIC(12,3),

    diferenca NUMERIC(12,3)
        GENERATED ALWAYS AS (
            quantidade_contada - quantidade_sistema
        ) STORED,

    observacao TEXT,
    contado_em TIMESTAMP,

    CONSTRAINT fk_inventario_item_inventario
        FOREIGN KEY (id_inventario)
        REFERENCES inventario_estoque(id_inventario),

    CONSTRAINT fk_inventario_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT fk_inventario_item_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote(id_lote),

    CONSTRAINT fk_inventario_item_classificacao
        FOREIGN KEY (id_classificacao)
        REFERENCES classificacao_estoque(id_classificacao),

    CONSTRAINT chk_inventario_quantidade_sistema
        CHECK (quantidade_sistema >= 0),

    CONSTRAINT chk_inventario_quantidade_contada
        CHECK (
            quantidade_contada IS NULL
            OR quantidade_contada >= 0
        )
);
