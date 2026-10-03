-- =========================================================
-- SCE - SISTEMA DE CONTROLE DE ESTOQUE E LOGÍSTICA
-- Arquivo: 03_vw_divergencia_inventario.sql
--
-- VIEW: DIVERGÊNCIA DE INVENTÁRIO
--
-- Objetivo:
-- Consolidar os resultados das contagens de inventário,
-- destacando diferenças entre o saldo registrado no sistema
-- e a quantidade física contada.
--
-- Esta view poderá ser utilizada em:
-- - inventário semanal;
-- - relatórios de divergência;
-- - análise de acuracidade;
-- - auditorias;
-- - dashboards gerenciais.
-- =========================================================


CREATE OR REPLACE VIEW vw_divergencia_inventario AS

SELECT
    i.id_inventario,
    i.data_contagem,

    i.status AS status_inventario,

    le.id_local,
    le.nome AS local_estoque,

    p.id_produto,
    p.codigo AS codigo_produto,
    p.descricao AS produto,

    ii.id_lote,
    l.numero_lote,
    l.tonalidade,
    l.calibre,

    ii.id_classificacao,
    ce.nome AS classificacao,

    ii.quantidade_sistema,
    ii.quantidade_contada,
    ii.diferenca,

    CASE
        WHEN ii.quantidade_contada IS NULL
            THEN 'NAO_CONTADO'

        WHEN ii.diferenca = 0
            THEN 'SEM_DIVERGENCIA'

        WHEN ii.diferenca > 0
            THEN 'SOBRA'

        WHEN ii.diferenca < 0
            THEN 'FALTA'

    END AS situacao_divergencia,

    CASE
        WHEN ii.quantidade_contada IS NULL
            THEN NULL

        WHEN ii.quantidade_sistema = 0
            THEN NULL

        ELSE ROUND(
            (
                ii.diferenca
                / ii.quantidade_sistema
            ) * 100,
            2
        )
    END AS percentual_divergencia,

    ii.observacao

FROM inventario_item ii

JOIN inventario_estoque i
    ON i.id_inventario = ii.id_inventario

JOIN local_estoque le
    ON le.id_local = i.id_local

JOIN produto p
    ON p.id_produto = ii.id_produto

LEFT JOIN lote l
    ON l.id_lote = ii.id_lote

JOIN classificacao_estoque ce
    ON ce.id_classificacao = ii.id_classificacao;
