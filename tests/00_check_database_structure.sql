-- =========================================================
-- MZT - CORE
-- Sistema integrado de operações
--
-- Arquivo: 00_check_database_structure.sql
--
-- CHECK: ESTRUTURA GERAL DO BANCO
--
-- Objetivo:
-- Conferir a estrutura atual do banco sem depender
-- de dados cadastrados.
--
-- Verifica:
-- - banco atual;
-- - usuário atual;
-- - tabelas;
-- - views;
-- - índices;
-- - triggers;
-- - funções;
-- - constraints;
-- - foreign keys.
-- =========================================================


-- =========================================================
-- 1. BANCO E USUÁRIO ATUAL
-- =========================================================

SELECT
    current_database() AS banco_atual,
    current_user AS usuario_atual;


-- =========================================================
-- 2. TABELAS DO SCHEMA PUBLIC
-- =========================================================

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- =========================================================
-- 3. VIEWS
-- =========================================================

SELECT
    table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;


-- =========================================================
-- 4. ÍNDICES
-- =========================================================

SELECT
    tablename AS tabela,
    indexname AS indice,
    indexdef AS definicao
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY
    tablename,
    indexname;


-- =========================================================
-- 5. TRIGGERS
-- =========================================================

SELECT
    event_object_table AS tabela,
    trigger_name,
    event_manipulation AS operacao,
    action_timing AS momento
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY
    event_object_table,
    trigger_name,
    event_manipulation;


-- =========================================================
-- 6. FUNÇÕES
-- =========================================================

SELECT
    routine_name AS funcao,
    data_type AS retorno
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
ORDER BY routine_name;


-- =========================================================
-- 7. TODAS AS CONSTRAINTS
-- =========================================================

SELECT
    tc.table_name AS tabela,
    tc.constraint_name AS constraint,
    tc.constraint_type AS tipo
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
ORDER BY
    tc.table_name,
    tc.constraint_type,
    tc.constraint_name;


-- =========================================================
-- 8. FOREIGN KEYS
-- =========================================================

SELECT
    tc.table_name AS tabela_origem,

    kcu.column_name AS coluna_origem,

    ccu.table_name AS tabela_destino,

    ccu.column_name AS coluna_destino,

    tc.constraint_name

FROM information_schema.table_constraints tc

JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema

JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema

WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'

ORDER BY
    tc.table_name,
    kcu.column_name;


-- =========================================================
-- 9. COLUNAS DE TODAS AS TABELAS
-- =========================================================

SELECT
    table_name AS tabela,
    column_name AS coluna,
    data_type AS tipo,
    is_nullable AS aceita_null,
    column_default AS valor_padrao

FROM information_schema.columns

WHERE table_schema = 'public'

ORDER BY
    table_name,
    ordinal_position;


-- =========================================================
-- 10. TRIGGERS DE UPDATED_AT
-- =========================================================

SELECT
    event_object_table AS tabela,
    trigger_name

FROM information_schema.triggers

WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'trg_%_updated_at'

ORDER BY
    event_object_table;


-- =========================================================
-- 11. TRIGGERS DE AUDITORIA
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


-- =========================================================
-- 12. FUNÇÕES IMPORTANTES DO MZT - CORE
-- =========================================================

SELECT
    routine_name

FROM information_schema.routines

WHERE routine_schema = 'public'

  AND routine_name IN (
      'fn_set_updated_at',
      'fn_criar_pesquisa_nps_pedido_entregue',
      'fn_registrar_auditoria',
      'fn_finalizar_inventario'
  )

ORDER BY routine_name;
