CREATE TABLE pedido (
    id_pedido BIGSERIAL PRIMARY KEY,
    numero_linx VARCHAR(50) NOT NULL UNIQUE,
    id_cliente BIGINT NOT NULL,
    id_vendedor BIGINT NOT NULL,

    data_venda DATE NOT NULL,
    data_entrega_original DATE NOT NULL,
    data_entrega_prevista DATE NOT NULL,

    status_atual VARCHAR(40) NOT NULL,

    nf_emitida BOOLEAN NOT NULL DEFAULT FALSE,
    numero_nf VARCHAR(50),
    data_emissao_nf DATE,

    observacao TEXT,

    created_by BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT fk_pedido_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id_vendedor),

    CONSTRAINT fk_pedido_usuario
        FOREIGN KEY (created_by)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_pedido_nf
        CHECK (
            (nf_emitida = FALSE AND numero_nf IS NULL)
            OR
            (nf_emitida = TRUE AND numero_nf IS NOT NULL)
        ),

    CONSTRAINT chk_pedido_status
        CHECK (
        status_atual IN (
            'CADASTRADO',
            'AGUARDANDO_MATERIAL',
            'COMPLETO',
            'RESERVADO_COMPLETO',
            'RESERVADO_INCOMPLETO',
            'AGUARDANDO_ENTREGA',
            'EM_ENTREGA',
            'ENTREGUE_PARCIAL',
            'ENTREGUE'
        )
)
);

CREATE TABLE pedido_item (
    id_pedido_item BIGSERIAL PRIMARY KEY,
    id_pedido BIGINT NOT NULL,
    id_produto BIGINT NOT NULL,

    quantidade_solicitada NUMERIC(12,3) NOT NULL,
    quantidade_reservada NUMERIC(12,3) NOT NULL DEFAULT 0,
    quantidade_separada NUMERIC(12,3) NOT NULL DEFAULT 0,
    quantidade_entregue NUMERIC(12,3) NOT NULL DEFAULT 0,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pedido_item_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_pedido_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT chk_pedido_item_quantidade
        CHECK (
            quantidade_solicitada > 0
            AND quantidade_reservada >= 0
            AND quantidade_separada >= 0
            AND quantidade_entregue >= 0
        )
);


CREATE TABLE pedido_status_historico (
    id_historico BIGSERIAL PRIMARY KEY,
    id_pedido BIGINT NOT NULL,
    status_anterior VARCHAR(40),
    status_novo VARCHAR(40) NOT NULL,
    id_usuario BIGINT NOT NULL,
    observacao TEXT,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_historico_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_historico_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
);


CREATE TABLE pedido_alteracao_prazo (
    id_alteracao BIGSERIAL PRIMARY KEY,
    id_pedido BIGINT NOT NULL,
    data_anterior DATE NOT NULL,
    nova_data DATE NOT NULL,
    justificativa TEXT NOT NULL,
    id_usuario BIGINT NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_alteracao_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_alteracao_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
);





-- SOLICITAÇÃO DE ENTREGA PARCIAL

CREATE TABLE solicitacao_entrega_parcial (
    id_solicitacao BIGSERIAL PRIMARY KEY,
    id_pedido BIGINT NOT NULL,

    tipo_solicitante VARCHAR(20) NOT NULL,
    id_cliente BIGINT,
    id_vendedor BIGINT,

    motivo TEXT,
    observacao TEXT,

    solicitado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    registrado_por BIGINT NOT NULL,

    CONSTRAINT fk_entrega_parcial_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_entrega_parcial_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT fk_entrega_parcial_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id_vendedor),

    CONSTRAINT fk_entrega_parcial_usuario
        FOREIGN KEY (registrado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_entrega_parcial_solicitante
        CHECK (
            (
                tipo_solicitante = 'CLIENTE'
                AND id_cliente IS NOT NULL
                AND id_vendedor IS NULL
            )
            OR
            (
                tipo_solicitante = 'VENDEDOR'
                AND id_vendedor IS NOT NULL
                AND id_cliente IS NULL
            )
        )
);
