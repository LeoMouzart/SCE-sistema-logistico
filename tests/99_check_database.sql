SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
    'recebimento_carga',
    'recebimento_carga_compra',
    'recebimento_carga_item'
)
ORDER BY table_name;


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
    'agendamento_entrega',
    'entrega',
    'entrega_item',
    'justificativa_entrega'
)
ORDER BY table_name;


SELECT *
FROM vw_estoque_disponivel
ORDER BY produto;


SELECT *
FROM vw_estoque_disponivel;


SELECT *
FROM vw_divergencia_inventario
ORDER BY
    data_contagem DESC,
    produto;


SELECT *
FROM vw_frete_mensal
ORDER BY data_pagamento_frete DESC;


SELECT
    mes_pagamento,
    SUM(valor_frete_total) AS total_frete_pago
FROM vw_frete_mensal
WHERE data_pagamento_frete IS NOT NULL
GROUP BY mes_pagamento
ORDER BY mes_pagamento;



SELECT
    column_name
FROM information_schema.columns
WHERE table_name = 'origem_material'
ORDER BY ordinal_position;
SELECT
    column_name
FROM information_schema.columns
WHERE table_name = 'solicitacao_material'
ORDER BY ordinal_position;


SELECT
    table_name,
    column_name
FROM information_schema.columns
WHERE table_name IN (
    'movimentacao_estoque',
    'justificativa_entrega'
)
ORDER BY
    table_name,
    ordinal_position;


SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;


SELECT
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'trg_pedido_criar_nps';
