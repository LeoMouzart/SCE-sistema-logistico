-- SCE - CADASTRO DE LOTES



CREATE TABLE lote (
    id_lote BIGSERIAL PRIMARY KEY,
    id_produto BIGINT NOT NULL,

    numero_lote VARCHAR(100) NOT NULL,
    tonalidade VARCHAR(50),
    calibre VARCHAR(50),

    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_lote_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),

    CONSTRAINT uq_lote_produto
        UNIQUE (id_produto, numero_lote)
);
