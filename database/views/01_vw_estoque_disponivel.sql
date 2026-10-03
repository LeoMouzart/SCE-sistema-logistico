-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 01_vw_estoque_disponivel.sql
--
-- VIEW: ESTOQUE DISPONÍVEL
--
-- Objetivo:
-- Consolidar o saldo físico de estoque com as reservas
-- ativas, permitindo visualizar a quantidade realmente
-- disponível para novas vendas ou separações.
--
-- Fórmula:
--
-- quantidade_disponivel =
-- saldo_fisico - quantidade_reservada
--
-- Considera como reserva ativa:
-- - ATIVA
-- - PARCIAL
-- =========================================================


CREATE OR REPLACE VIEW vw_estoque_disponivel AS

SELECT
    es.id_estoque,

    p.id_produto,
    p.codigo AS codigo_produto,
    p.descricao AS produto,

    es.id_lote,
    l.numero_lote,
    l.tonalidade,
    l.calibre,

    es.id_local,
    le.nome AS local_estoque,

    es.id_classificacao,
    ce.nome AS classificacao,

    es.quantidade AS saldo_fisico,

    COALESCE(
        SUM(
            CASE
                WHEN re.status IN ('ATIVA', 'PARCIAL')
                    THEN re.quantidade_reservada
                ELSE 0
            END
        ),
        0
    ) AS quantidade_reservada,

    es.quantidade
    -
    COALESCE(
        SUM(
            CASE
                WHEN re.status IN ('ATIVA', 'PARCIAL')
                    THEN re.quantidade_reservada
                ELSE 0
            END
        ),
        0
    ) AS quantidade_disponivel

FROM estoque_saldo es

JOIN produto p
    ON p.id_produto = es.id_produto

LEFT JOIN lote l
    ON l.id_lote = es.id_lote

JOIN local_estoque le
    ON le.id_local = es.id_local

JOIN classificacao_estoque ce
    ON ce.id_classificacao = es.id_classificacao

LEFT JOIN reserva_estoque re
    ON re.id_produto = es.id_produto

    AND re.id_local = es.id_local

    AND re.id_classificacao = es.id_classificacao

    AND (
        re.id_lote = es.id_lote
        OR (
            re.id_lote IS NULL
            AND es.id_lote IS NULL
        )
    )

GROUP BY
    es.id_estoque,

    p.id_produto,
    p.codigo,
    p.descricao,

    es.id_lote,
    l.numero_lote,
    l.tonalidade,
    l.calibre,

    es.id_local,
    le.nome,

    es.id_classificacao,
    ce.nome,

    es.quantidade;
