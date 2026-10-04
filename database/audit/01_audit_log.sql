-- =========================================================
-- MZT - CORE
-- Sistema integrado de operações
--
-- Arquivo: 01_audit_log.sql
--
-- MÓDULO: AUDITORIA
--
-- Objetivo:
-- Registrar automaticamente alterações realizadas em
-- tabelas críticas do sistema.
--
-- Operações auditadas:
-- - INSERT
-- - UPDATE
-- - DELETE
--
-- A auditoria registra:
-- - tabela alterada;
-- - tipo da operação;
-- - dados anteriores;
-- - dados novos;
-- - usuário do PostgreSQL;
-- - usuário da aplicação, quando disponível;
-- - data e hora da operação.
-- =========================================================


-- =========================================================
-- TABELA DE AUDITORIA
-- =========================================================

CREATE TABLE IF NOT EXISTS audit_log (

    id_audit BIGSERIAL PRIMARY KEY,

    tabela VARCHAR(100) NOT NULL,

    operacao VARCHAR(10) NOT NULL,

    dados_anteriores JSONB,

    dados_novos JSONB,

    usuario_banco VARCHAR(100) NOT NULL,

    id_usuario_aplicacao BIGINT,

    data_operacao TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_audit_operacao
        CHECK (
            operacao IN (
                'INSERT',
                'UPDATE',
                'DELETE'
            )
        )
);


-- =========================================================
-- ÍNDICES DA AUDITORIA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_audit_tabela
ON audit_log(tabela);


CREATE INDEX IF NOT EXISTS idx_audit_operacao
ON audit_log(operacao);


CREATE INDEX IF NOT EXISTS idx_audit_data
ON audit_log(data_operacao);


CREATE INDEX IF NOT EXISTS idx_audit_usuario_aplicacao
ON audit_log(id_usuario_aplicacao);



-- =========================================================
-- FUNÇÃO GENÉRICA DE AUDITORIA
-- =========================================================

CREATE OR REPLACE FUNCTION fn_registrar_auditoria()
RETURNS TRIGGER
AS $$

DECLARE

    usuario_app BIGINT;

BEGIN

    -- Tenta recuperar o usuário da aplicação.
    --
    -- Futuramente o Django poderá informar ao PostgreSQL
    -- qual usuário está executando a operação.
    --
    -- Caso ainda não exista usuário da aplicação,
    -- o valor permanecerá NULL.

    BEGIN

        usuario_app :=
            NULLIF(
                current_setting(
                    'app.user_id',
                    true
                ),
                ''
            )::BIGINT;

    EXCEPTION
        WHEN OTHERS THEN
            usuario_app := NULL;
    END;


    -- =====================================================
    -- INSERT
    -- =====================================================

    IF TG_OP = 'INSERT' THEN

        INSERT INTO audit_log (
            tabela,
            operacao,
            dados_anteriores,
            dados_novos,
            usuario_banco,
            id_usuario_aplicacao
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            NULL,
            to_jsonb(NEW),
            CURRENT_USER,
            usuario_app
        );

        RETURN NEW;


    -- =====================================================
    -- UPDATE
    -- =====================================================

    ELSIF TG_OP = 'UPDATE' THEN

        INSERT INTO audit_log (
            tabela,
            operacao,
            dados_anteriores,
            dados_novos,
            usuario_banco,
            id_usuario_aplicacao
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            to_jsonb(OLD),
            to_jsonb(NEW),
            CURRENT_USER,
            usuario_app
        );

        RETURN NEW;


    -- =====================================================
    -- DELETE
    -- =====================================================

    ELSIF TG_OP = 'DELETE' THEN

        INSERT INTO audit_log (
            tabela,
            operacao,
            dados_anteriores,
            dados_novos,
            usuario_banco,
            id_usuario_aplicacao
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            to_jsonb(OLD),
            NULL,
            CURRENT_USER,
            usuario_app
        );

        RETURN OLD;

    END IF;


    RETURN NULL;

END;

$$ LANGUAGE plpgsql;



-- =========================================================
-- CRIAÇÃO AUTOMÁTICA DOS TRIGGERS DE AUDITORIA
-- =========================================================

-- =========================================================

DO $$

DECLARE

    nome_tabela TEXT;

    tabelas_auditoria TEXT[] := ARRAY[

        'pedido',
        'pedido_item',

        'estoque_saldo',
        'movimentacao_estoque',
        'reserva_estoque',

        'inventario_estoque',
        'inventario_item',

        'solicitacao_material',
        'pedido_compra',
        'pedido_compra_item',

        'recebimento_carga',
        'recebimento_carga_item',

        'agendamento_entrega',
        'entrega',
        'entrega_item',
        'justificativa_entrega',

        'pesquisa_nps',
        'resposta_nps'

    ];

BEGIN

    FOREACH nome_tabela
    IN ARRAY tabelas_auditoria

    LOOP

        -- Só cria o trigger se a tabela realmente existir.

        IF to_regclass(
            'public.' || nome_tabela
        ) IS NOT NULL THEN


            -- Remove trigger anterior, caso exista.

            EXECUTE format(
                'DROP TRIGGER IF EXISTS %I ON %I;',
                'trg_audit_' || nome_tabela,
                nome_tabela
            );


            -- Cria trigger de auditoria.

            EXECUTE format(
                'CREATE TRIGGER %I
                 AFTER INSERT OR UPDATE OR DELETE
                 ON %I
                 FOR EACH ROW
                 EXECUTE FUNCTION fn_registrar_auditoria();',

                'trg_audit_' || nome_tabela,
                nome_tabela
            );


            RAISE NOTICE
                'Auditoria ativada na tabela: %',
                nome_tabela;

        ELSE

            RAISE NOTICE
                'Tabela não encontrada e ignorada: %',
                nome_tabela;

        END IF;

    END LOOP;

END;
$$;



-- =========================================================
-- CHECK
--
-- Exibe os triggers de auditoria criados.
-- =========================================================

SELECT
    event_object_table AS tabela,
    trigger_name,
    event_manipulation AS operacao

FROM information_schema.triggers

WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'trg_audit_%'

ORDER BY
    event_object_table,
    event_manipulation;
