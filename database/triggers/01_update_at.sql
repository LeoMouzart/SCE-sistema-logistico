-- =========================================================
-- MZT - CORE
-- Sistema integrado de operações
--
-- Arquivo: 01_updated_at.sql
--
-- MÓDULO: TRIGGERS
--
-- Objetivo:
-- Atualizar automaticamente a coluna updated_at
-- sempre que um registro for alterado.
--


-- =========================================================
-- FUNÇÃO GENÉRICA PARA ATUALIZAR updated_at
-- =========================================================

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER
AS $$
BEGIN

    NEW.updated_at = CURRENT_TIMESTAMP;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;


-- =========================================================
-- CRIAÇÃO AUTOMÁTICA DOS TRIGGERS
-- =========================================================
--
-- Procura todas as tabelas do schema public que possuem
-- a coluna updated_at.
--
-- Para cada tabela encontrada:
--
-- 1. Remove o trigger anterior, caso exista.
-- 2. Cria novamente o trigger.
--
-- =========================================================

DO $$
DECLARE

    tabela RECORD;
    nome_trigger TEXT;

BEGIN

    FOR tabela IN

        SELECT DISTINCT
            c.table_name

        FROM information_schema.columns c

        JOIN information_schema.tables t
            ON t.table_schema = c.table_schema
            AND t.table_name = c.table_name

        WHERE c.table_schema = 'public'
          AND c.column_name = 'updated_at'
          AND t.table_type = 'BASE TABLE'

        ORDER BY c.table_name

    LOOP

        nome_trigger :=
            'trg_' || tabela.table_name || '_updated_at';


        -- Remove o trigger caso ele já exista

        EXECUTE format(
            'DROP TRIGGER IF EXISTS %I ON %I;',
            nome_trigger,
            tabela.table_name
        );


        -- Cria o trigger novamente

        EXECUTE format(
            'CREATE TRIGGER %I
             BEFORE UPDATE
             ON %I
             FOR EACH ROW
             EXECUTE FUNCTION fn_set_updated_at();',
            nome_trigger,
            tabela.table_name
        );


        RAISE NOTICE
            'Trigger criado: % na tabela %',
            nome_trigger,
            tabela.table_name;

    END LOOP;

END;
$$;


-- =========================================================
-- CHECK
--
-- Lista todos os triggers updated_at criados.
-- =========================================================

SELECT
    event_object_table AS tabela,
    trigger_name

FROM information_schema.triggers

WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'trg_%_updated_at'

ORDER BY
    event_object_table;
