-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 08_nps_tables.sql
--
-- MÓDULO: NPS / SATISFAÇÃO DO CLIENTE
--
-- Objetivo:
-- Registrar pesquisas de satisfação enviadas após a entrega
-- e armazenar as respostas dos clientes.
--
-- Este módulo controla:
-- - pedido relacionado;
-- - cliente relacionado;
-- - vendedor responsável pela venda de forma indireta,
--   através do pedido;
-- - data de envio da pesquisa;
-- - status da pesquisa;
-- - identificação do respondente;
-- - canal da resposta;
-- - nota NPS;
-- - comentário / feedback;
-- - data da resposta.
--
-- Relação esperada:
--
-- RESPOSTA NPS
--      ↓
-- PESQUISA NPS
--      ↓
-- PEDIDO
--      ↓
-- CLIENTE
--      ↓
-- VENDEDOR
--
-- Dessa forma será possível gerar relatórios de satisfação
-- por pedido, cliente e vendedor, sem duplicar informações.
-- =========================================================



-- =========================================================
-- PESQUISA NPS
--
-- Finalidade:
-- Representar uma pesquisa de satisfação associada a um
-- pedido entregue ao cliente.
--
-- Cada pesquisa estará relacionada ao pedido e ao cliente.
-- O vendedor responsável será identificado posteriormente
-- através da relação do pedido com a tabela vendedor.
-- =========================================================

CREATE TABLE pesquisa_nps (
    id_pesquisa BIGSERIAL PRIMARY KEY,

    id_pedido BIGINT NOT NULL,
    id_cliente BIGINT NOT NULL,

    data_envio TIMESTAMP,

    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_nps_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_nps_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT chk_nps_status
        CHECK (
            status IN (
                'PENDENTE',
                'ENVIADA',
                'RESPONDIDA'
            )
        ),

    CONSTRAINT uq_nps_pedido
        UNIQUE (id_pedido)
);



-- =========================================================
-- RESPOSTA NPS
--
-- Finalidade:
-- Registrar a resposta enviada pelo cliente referente à
-- pesquisa de satisfação.
--
-- Permite identificar:
-- - quem respondeu;
-- - canal utilizado;
-- - nota de 0 a 10;
-- - comentário / feedback;
-- - data da resposta.
--
-- A partir da pesquisa é possível rastrear:
-- pedido → cliente → vendedor.
-- =========================================================

CREATE TABLE resposta_nps (
    id_resposta BIGSERIAL PRIMARY KEY,

    id_pesquisa BIGINT NOT NULL,

    nome_respondente VARCHAR(150),
    email_respondente VARCHAR(150),
    telefone_respondente VARCHAR(30),

    canal_resposta VARCHAR(20),

    nota INTEGER NOT NULL,

    comentario TEXT,

    data_resposta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resposta_nps_pesquisa
        FOREIGN KEY (id_pesquisa)
        REFERENCES pesquisa_nps(id_pesquisa),

    CONSTRAINT chk_nps_nota
        CHECK (
            nota BETWEEN 0 AND 10
        ),

    CONSTRAINT chk_nps_canal
        CHECK (
            canal_resposta IS NULL
            OR canal_resposta IN (
                'EMAIL',
                'WHATSAPP',
                'LINK',
                'TELEFONE'
            )
        ),

    CONSTRAINT uq_resposta_nps
        UNIQUE (id_pesquisa)
);
