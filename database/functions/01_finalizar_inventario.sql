-- =========================================================
-- MZT - CORE
-- Sistema integrado de operações
--
-- Arquivo: 01_finalizar_inventario.sql
--
-- MÓDULO: INVENTÁRIO / AJUSTE DE ESTOQUE
--
-- Objetivo:
-- Finalizar um inventário conferido e aplicar automaticamente
-- as divergências encontradas ao saldo de estoque.
--
-- Regras:
-- - O inventário precisa existir.
-- - O inventário precisa estar com status CONFERIDO.
-- - Todos os itens precisam ter sido contados.
-- - Itens sem divergência não geram movimentação.
-- - Sobras aumentam o estoque.
-- - Faltas reduzem o estoque.
-- - Toda alteração gera movimentação AJUSTE_INVENTARIO.
-- - O estoque nunca poderá ficar negativo.
-- - Ao final, o inventário passa para FINALIZADO.
--
-- IMPORTANTE:
-- A função inteira é executada dentro da mesma transação.
-- Se algum ajuste falhar, nenhuma alteração é confirmada.
-- =========================================================


CREATE OR REPLACE FUNCTION fn_finalizar_inventario(
    p_id_inventario BIGINT,
    p_id_usuario BIGINT
)
RETURNS VOID
AS $$

DECLARE

    v_status VARCHAR(30);
    v_id_local BIGINT;

    v_item RECORD;

BEGIN

    -- =====================================================
    -- 1. LOCALIZA E BLOQUEIA O INVENTÁRIO
    -- =====================================================

    SELECT
        status,
        id_local
    INTO
        v_status,
        v_id_local

    FROM inventario_estoque

    WHERE id_inventario = p_id_inventario

    FOR UPDATE;


    -- Inventário inexistente

    IF NOT FOUND THEN

        RAISE EXCEPTION
            'Inventário % não encontrado.',
            p_id_inventario;

    END IF;


    -- =====================================================
    -- 2. VERIFICA STATUS
    -- =====================================================

    IF v_status = 'FINALIZADO' THEN

        RAISE EXCEPTION
            'Inventário % já foi finalizado.',
            p_id_inventario;

    END IF;


    IF v_status <> 'CONFERIDO' THEN

        RAISE EXCEPTION
            'Inventário % precisa estar CONFERIDO antes da finalização. Status atual: %',
            p_id_inventario,
            v_status;

    END IF;


    -- =====================================================
    -- 3. VERIFICA SE TODOS OS ITENS FORAM CONTADOS
    -- =====================================================

    IF EXISTS (

        SELECT 1

        FROM inventario_item

        WHERE id_inventario = p_id_inventario
          AND quantidade_contada IS NULL

    ) THEN

        RAISE EXCEPTION
            'Inventário % possui itens ainda não contados.',
            p_id_inventario;

    END IF;


    -- =====================================================
    -- 4. PROCESSA SOMENTE ITENS COM DIVERGÊNCIA
    -- =====================================================

    FOR v_item IN

        SELECT
            id_inventario_item,
            id_produto,
            id_lote,
            id_classificacao,
            quantidade_sistema,
            quantidade_contada,
            diferenca

        FROM inventario_item

        WHERE id_inventario = p_id_inventario
          AND diferenca <> 0

    LOOP


        -- =================================================
        -- FALTA DE ESTOQUE


        IF v_item.diferenca < 0 THEN


            UPDATE estoque_saldo

            SET
                quantidade =
                    quantidade + v_item.diferenca

            WHERE id_produto = v_item.id_produto

              AND id_local = v_id_local

              AND id_classificacao =
                  v_item.id_classificacao

              AND (
                    id_lote = v_item.id_lote

                    OR (
                        id_lote IS NULL
                        AND v_item.id_lote IS NULL
                    )
                  )

              -- Impede estoque negativo
              AND quantidade + v_item.diferenca >= 0;




            IF NOT FOUND THEN

                RAISE EXCEPTION
                    'Não foi possível aplicar falta do produto %. Saldo inexistente ou insuficiente.',
                    v_item.id_produto;

            END IF;


            -- Registra a movimentação

            INSERT INTO movimentacao_estoque (

                id_produto,
                id_lote,

                id_local_origem,
                id_local_destino,

                id_classificacao_origem,
                id_classificacao_destino,

                tipo_movimentacao,

                quantidade,

                id_pedido,
                id_usuario,

                obs

            )
            VALUES (

                v_item.id_produto,
                v_item.id_lote,

                v_id_local,
                NULL,

                v_item.id_classificacao,
                NULL,

                'AJUSTE_INVENTARIO',

                ABS(v_item.diferenca),

                NULL,
                p_id_usuario,

                FORMAT(
                    'Ajuste automático referente ao inventário %s - falta identificada.',
                    p_id_inventario
                )

            );



        -- =================================================

        ELSE


            UPDATE estoque_saldo

            SET
                quantidade =
                    quantidade + v_item.diferenca

            WHERE id_produto = v_item.id_produto

              AND id_local = v_id_local

              AND id_classificacao =
                  v_item.id_classificacao

              AND (
                    id_lote = v_item.id_lote

                    OR (
                        id_lote IS NULL
                        AND v_item.id_lote IS NULL
                    )
                  );


            -- =================================================
            -- Se ainda não existir saldo para produto/lote/local,
            -- cria a posição de estoque.
            -- =================================================

            IF NOT FOUND THEN

                INSERT INTO estoque_saldo (

                    id_produto,
                    id_lote,
                    id_local,
                    id_classificacao,
                    quantidade

                )
                VALUES (

                    v_item.id_produto,
                    v_item.id_lote,
                    v_id_local,
                    v_item.id_classificacao,
                    v_item.diferenca

                );

            END IF;


            -- Registra a movimentação

            INSERT INTO movimentacao_estoque (

                id_produto,
                id_lote,

                id_local_origem,
                id_local_destino,

                id_classificacao_origem,
                id_classificacao_destino,

                tipo_movimentacao,

                quantidade,

                id_pedido,
                id_usuario,

                obs

            )
            VALUES (

                v_item.id_produto,
                v_item.id_lote,

                NULL,
                v_id_local,

                NULL,
                v_item.id_classificacao,

                'AJUSTE_INVENTARIO',

                v_item.diferenca,

                NULL,
                p_id_usuario,

                FORMAT(
                    'Ajuste automático referente ao inventário %s - sobra identificada.',
                    p_id_inventario
                )

            );

        END IF;

    END LOOP;


    -- =====================================================
    -- 5. FINALIZA O INVENTÁRIO
    -- =====================================================

    UPDATE inventario_estoque

    SET
        status = 'FINALIZADO',
        finalizado_em = CURRENT_TIMESTAMP

    WHERE id_inventario = p_id_inventario;


END;

$$ LANGUAGE plpgsql;
