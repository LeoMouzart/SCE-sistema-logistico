-- =========================================================
-- MZT - CORE
-- Sistema integrado de operações
--
-- Arquivo: 02_nps_on_delivery.sql
--
-- MÓDULO: TRIGGER DE NPS
--
-- Objetivo:
-- Criar automaticamente uma pesquisa NPS quando um pedido
-- tiver seu status alterado para ENTREGUE.
--
-- Regra:
-- - ENTREGUE_PARCIAL não gera NPS.
-- - ENTREGUE gera uma pesquisa NPS.
-- - Cada pedido pode possuir apenas uma pesquisa NPS.
-- =========================================================


-- =========================================================
-- FUNÇÃO
-- =========================================================

CREATE OR REPLACE FUNCTION fn_criar_pesquisa_nps_pedido_entregue()
RETURNS TRIGGER
AS $$
BEGIN


    IF NEW.status_atual = 'ENTREGUE'
       AND OLD.status_atual IS DISTINCT FROM NEW.status_atual
    THEN

        INSERT INTO pesquisa_nps (
            id_pedido,
            id_cliente,
            status
        )
        VALUES (
            NEW.id_pedido,
            NEW.id_cliente,
            'PENDENTE'
        )


        ON CONFLICT (id_pedido)
        DO NOTHING;

    END IF;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;


-- =========================================================
-- TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_pedido_criar_nps
ON pedido;


CREATE TRIGGER trg_pedido_criar_nps

AFTER UPDATE OF status_atual
ON pedido

FOR EACH ROW

EXECUTE FUNCTION fn_criar_pesquisa_nps_pedido_entregue();
