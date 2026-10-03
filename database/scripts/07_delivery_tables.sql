-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 07_delivery_tables.sql
--
-- MÓDULO: ENTREGA AO CLIENTE
--
-- Objetivo:
-- Controlar a etapa final do pedido, desde o agendamento
-- da entrega até a confirmação da entrega total ou parcial.
--
-- Este módulo controla:
-- - data prevista/agendada;
-- - alteração de data;
-- - transportadora responsável;
-- - motorista;
-- - saída para entrega;
-- - entrega total;
-- - entrega parcial;
-- - itens e quantidades entregues;
-- - atraso;
-- - justificativa;
-- - usuário responsável pelo registro.
--
-- Fluxo esperado:
--
-- PEDIDO COMPLETO
--      ↓
-- AGUARDANDO ENTREGA
--      ↓
-- ENTREGA AGENDADA
--      ↓
-- EM ENTREGA
--      ↓
-- ENTREGUE PARCIAL
--        ou
-- ENTREGUE
-- =========================================================



-- =========================================================
-- AGENDAMENTO DE ENTREGA
--
-- Finalidade:
-- Registrar a data planejada para entrega ao cliente.
--
-- Permite manter histórico de alterações sem perder
-- a data originalmente agendada.
--
-- Também registra quem fez o agendamento.
-- =========================================================

CREATE TABLE agendamento_entrega (
    id_agendamento BIGSERIAL PRIMARY KEY,

    id_pedido BIGINT NOT NULL,

    data_agendada DATE NOT NULL,
    periodo VARCHAR(20),

    observacao TEXT,

    agendado_por BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_agendamento_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_agendamento_usuario
        FOREIGN KEY (agendado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_agendamento_periodo
        CHECK (
            periodo IS NULL
            OR periodo IN (
                'MANHA',
                'TARDE',
                'INTEGRAL'
            )
        )
);



-- =========================================================
-- ENTREGA
--
-- Finalidade:
-- Registrar a execução real da entrega.
--
-- Uma entrega representa uma saída física de mercadoria
-- destinada ao cliente.
--
-- Um mesmo pedido pode possuir mais de uma entrega,
-- especialmente em casos de entrega parcial.
-- =========================================================

CREATE TABLE entrega (
    id_entrega BIGSERIAL PRIMARY KEY,

    id_pedido BIGINT NOT NULL,
    id_agendamento BIGINT,

    id_transportadora BIGINT,
    id_motorista BIGINT,

    data_saida DATE,
    hora_saida TIME,

    data_entrega DATE,
    hora_entrega TIME,

    status VARCHAR(30) NOT NULL DEFAULT 'AGUARDANDO_ENTREGA',

    cidade VARCHAR(100),
    regiao VARCHAR(100),

    observacao TEXT,

    registrado_por BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_entrega_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_entrega_agendamento
        FOREIGN KEY (id_agendamento)
        REFERENCES agendamento_entrega(id_agendamento),

    CONSTRAINT fk_entrega_transportadora
        FOREIGN KEY (id_transportadora)
        REFERENCES transportadora(id_transportadora),

    CONSTRAINT fk_entrega_motorista
        FOREIGN KEY (id_motorista)
        REFERENCES motorista(id_motorista),

    CONSTRAINT fk_entrega_usuario
        FOREIGN KEY (registrado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_entrega_status
        CHECK (
            status IN (
                'AGUARDANDO_ENTREGA',
                'EM_ENTREGA',
                'ENTREGUE_PARCIAL',
                'ENTREGUE'
            )
        )
);



-- =========================================================
-- ITENS DA ENTREGA
--
-- Finalidade:
-- Registrar exatamente quais itens e quantidades
-- foram enviados em cada entrega.
--
-- Isso é importante principalmente para entregas parciais.
--
-- Permite saber:
-- - o que saiu;
-- - quanto saiu;
-- - o que ainda ficou pendente.
-- =========================================================

CREATE TABLE entrega_item (
    id_entrega_item BIGSERIAL PRIMARY KEY,

    id_entrega BIGINT NOT NULL,
    id_pedido_item BIGINT NOT NULL,

    quantidade_entregue NUMERIC(12,3) NOT NULL,

    observacao TEXT,

    CONSTRAINT fk_entrega_item_entrega
        FOREIGN KEY (id_entrega)
        REFERENCES entrega(id_entrega),

    CONSTRAINT fk_entrega_item_pedido_item
        FOREIGN KEY (id_pedido_item)
        REFERENCES pedido_item(id_pedido_item),

    CONSTRAINT chk_entrega_item_quantidade
        CHECK (
            quantidade_entregue > 0
        )
);



-- =========================================================
-- JUSTIFICATIVA DE ENTREGA / ATRASO
--
-- Finalidade:
-- Registrar motivos de atraso, mudança de data ou qualquer
-- ocorrência relevante relacionada à entrega.
--
-- Esse histórico será utilizado posteriormente em:
-- - relatórios de atraso;
-- - análise de motivos;
-- - indicadores logísticos;
-- - dashboards gerenciais.
-- =========================================================

CREATE TABLE justificativa_entrega (
    id_justificativa BIGSERIAL PRIMARY KEY,

    id_pedido BIGINT NOT NULL,
    id_entrega BIGINT,

    tipo VARCHAR(30) NOT NULL,

    justificativa TEXT NOT NULL,

    registrado_por BIGINT NOT NULL,

    registrado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_justificativa_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),

    CONSTRAINT fk_justificativa_entrega
        FOREIGN KEY (id_entrega)
        REFERENCES entrega(id_entrega),

    CONSTRAINT fk_justificativa_usuario
        FOREIGN KEY (registrado_por)
        REFERENCES usuario(id_usuario),

    CONSTRAINT chk_justificativa_tipo
        CHECK (
            tipo IN (
                'ATRASO',
                'ALTERACAO_DATA',
                'CLIENTE',
                'TRANSPORTADORA',
                'MATERIAL',
                'OPERACIONAL',
                'OUTROS'
            )
        )
);
