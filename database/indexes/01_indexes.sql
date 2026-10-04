-- =========================================================
-- MZT - CORE
-- Sistema integrado de operações
--
-- Arquivo: 01_indexes.sql
--
-- MÓDULO: ÍNDICES
--
-- Objetivo:
-- Criar índices para melhorar o desempenho das consultas,
-- relacionamentos, filtros, relatórios e dashboards.
--

-- =========================================================



-- =========================================================
-- CLIENTES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_cliente_nome
ON cliente(nome_razao_social);

CREATE INDEX IF NOT EXISTS idx_cliente_cpf_cnpj
ON cliente(cpf_cnpj);

CREATE INDEX IF NOT EXISTS idx_cliente_cidade_estado
ON cliente(cidade, estado);

CREATE INDEX IF NOT EXISTS idx_cliente_ativo
ON cliente(ativo);



-- =========================================================
-- VENDEDORES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_vendedor_nome
ON vendedor(nome);

CREATE INDEX IF NOT EXISTS idx_vendedor_ativo
ON vendedor(ativo);



-- =========================================================
-- PRODUTOS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_produto_descricao
ON produto(descricao);

CREATE INDEX IF NOT EXISTS idx_produto_categoria
ON produto(id_categoria);

CREATE INDEX IF NOT EXISTS idx_produto_fabricante
ON produto(id_fabricante);

CREATE INDEX IF NOT EXISTS idx_produto_ativo
ON produto(ativo);



-- =========================================================
-- LOTES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_lote_produto
ON lote(id_produto);

CREATE INDEX IF NOT EXISTS idx_lote_numero
ON lote(numero_lote);

CREATE INDEX IF NOT EXISTS idx_lote_tonalidade
ON lote(tonalidade);

CREATE INDEX IF NOT EXISTS idx_lote_ativo
ON lote(ativo);



-- =========================================================
-- MOTORISTAS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_motorista_transportadora
ON motorista(id_transportadora);

CREATE INDEX IF NOT EXISTS idx_motorista_nome
ON motorista(nome);

CREATE INDEX IF NOT EXISTS idx_motorista_ativo
ON motorista(ativo);



-- =========================================================
-- PEDIDOS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pedido_cliente
ON pedido(id_cliente);

CREATE INDEX IF NOT EXISTS idx_pedido_vendedor
ON pedido(id_vendedor);

CREATE INDEX IF NOT EXISTS idx_pedido_status
ON pedido(status_atual);

CREATE INDEX IF NOT EXISTS idx_pedido_data_venda
ON pedido(data_venda);

CREATE INDEX IF NOT EXISTS idx_pedido_data_entrega_prevista
ON pedido(data_entrega_prevista);

CREATE INDEX IF NOT EXISTS idx_pedido_cliente_status
ON pedido(id_cliente, status_atual);

CREATE INDEX IF NOT EXISTS idx_pedido_vendedor_status
ON pedido(id_vendedor, status_atual);

CREATE INDEX IF NOT EXISTS idx_pedido_status_entrega
ON pedido(status_atual, data_entrega_prevista);



-- =========================================================
-- ITENS DOS PEDIDOS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pedido_item_pedido
ON pedido_item(id_pedido);

CREATE INDEX IF NOT EXISTS idx_pedido_item_produto
ON pedido_item(id_produto);

CREATE INDEX IF NOT EXISTS idx_pedido_item_pedido_produto
ON pedido_item(id_pedido, id_produto);



-- =========================================================
-- HISTÓRICO DE STATUS DOS PEDIDOS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pedido_status_historico_pedido
ON pedido_status_historico(id_pedido);

CREATE INDEX IF NOT EXISTS idx_pedido_status_historico_usuario
ON pedido_status_historico(id_usuario);



-- =========================================================
-- ALTERAÇÕES DE PRAZO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pedido_alteracao_prazo_pedido
ON pedido_alteracao_prazo(id_pedido);

CREATE INDEX IF NOT EXISTS idx_pedido_alteracao_prazo_usuario
ON pedido_alteracao_prazo(id_usuario);



-- =========================================================
-- SOLICITAÇÃO DE ENTREGA PARCIAL
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_solicitacao_entrega_parcial_pedido
ON solicitacao_entrega_parcial(id_pedido);

CREATE INDEX IF NOT EXISTS idx_solicitacao_entrega_parcial_cliente
ON solicitacao_entrega_parcial(id_cliente);

CREATE INDEX IF NOT EXISTS idx_solicitacao_entrega_parcial_vendedor
ON solicitacao_entrega_parcial(id_vendedor);



-- =========================================================
-- ESTOQUE SALDO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_estoque_saldo_produto
ON estoque_saldo(id_produto);

CREATE INDEX IF NOT EXISTS idx_estoque_saldo_lote
ON estoque_saldo(id_lote);

CREATE INDEX IF NOT EXISTS idx_estoque_saldo_local
ON estoque_saldo(id_local);

CREATE INDEX IF NOT EXISTS idx_estoque_saldo_classificacao
ON estoque_saldo(id_classificacao);

CREATE INDEX IF NOT EXISTS idx_estoque_saldo_produto_local
ON estoque_saldo(id_produto, id_local);

CREATE INDEX IF NOT EXISTS idx_estoque_saldo_produto_lote_local
ON estoque_saldo(id_produto, id_lote, id_local);



-- =========================================================
-- MOVIMENTAÇÃO DE ESTOQUE
-- =========================================================

-- =========================================================
-- MOVIMENTAÇÃO DE ESTOQUE
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_movimentacao_produto
ON movimentacao_estoque(id_produto);

CREATE INDEX IF NOT EXISTS idx_movimentacao_lote
ON movimentacao_estoque(id_lote);

CREATE INDEX IF NOT EXISTS idx_movimentacao_pedido
ON movimentacao_estoque(id_pedido);

CREATE INDEX IF NOT EXISTS idx_movimentacao_tipo
ON movimentacao_estoque(tipo_movimentacao);

CREATE INDEX IF NOT EXISTS idx_movimentacao_local_origem
ON movimentacao_estoque(id_local_origem);

CREATE INDEX IF NOT EXISTS idx_movimentacao_local_destino
ON movimentacao_estoque(id_local_destino);

CREATE INDEX IF NOT EXISTS idx_movimentacao_usuario
ON movimentacao_estoque(id_usuario);



-- =========================================================
-- RESERVAS DE ESTOQUE
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_reserva_pedido
ON reserva_estoque(id_pedido);

CREATE INDEX IF NOT EXISTS idx_reserva_pedido_item
ON reserva_estoque(id_pedido_item);

CREATE INDEX IF NOT EXISTS idx_reserva_produto
ON reserva_estoque(id_produto);

CREATE INDEX IF NOT EXISTS idx_reserva_lote
ON reserva_estoque(id_lote);

CREATE INDEX IF NOT EXISTS idx_reserva_local
ON reserva_estoque(id_local);

CREATE INDEX IF NOT EXISTS idx_reserva_classificacao
ON reserva_estoque(id_classificacao);

CREATE INDEX IF NOT EXISTS idx_reserva_status
ON reserva_estoque(status);

CREATE INDEX IF NOT EXISTS idx_reserva_produto_status
ON reserva_estoque(id_produto, status);

CREATE INDEX IF NOT EXISTS idx_reserva_pedido_status
ON reserva_estoque(id_pedido, status);



-- =========================================================
-- INVENTÁRIOS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventario_local
ON inventario_estoque(id_local);

CREATE INDEX IF NOT EXISTS idx_inventario_status
ON inventario_estoque(status);

CREATE INDEX IF NOT EXISTS idx_inventario_data
ON inventario_estoque(data_contagem);

CREATE INDEX IF NOT EXISTS idx_inventario_local_data
ON inventario_estoque(id_local, data_contagem);



-- =========================================================
-- ITENS DE INVENTÁRIO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventario_item_inventario
ON inventario_item(id_inventario);

CREATE INDEX IF NOT EXISTS idx_inventario_item_produto
ON inventario_item(id_produto);

CREATE INDEX IF NOT EXISTS idx_inventario_item_lote
ON inventario_item(id_lote);

CREATE INDEX IF NOT EXISTS idx_inventario_item_classificacao
ON inventario_item(id_classificacao);

CREATE INDEX IF NOT EXISTS idx_inventario_item_inventario_produto
ON inventario_item(id_inventario, id_produto);



-- =========================================================
-- PROMOTORES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_promotor_fabricante
ON promotor(id_fabricante);

CREATE INDEX IF NOT EXISTS idx_promotor_ativo
ON promotor(ativo);



-- =========================================================
-- NEGOCIAÇÕES COM PROMOTORES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_negociacao_promotor
ON negociacao_promotor(id_promotor);

CREATE INDEX IF NOT EXISTS idx_negociacao_produto
ON negociacao_promotor(id_produto);

CREATE INDEX IF NOT EXISTS idx_negociacao_data
ON negociacao_promotor(data_negociacao);



-- =========================================================
-- SOLICITAÇÕES DE MATERIAL
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_solicitacao_material_pedido
ON solicitacao_material(id_pedido);

CREATE INDEX IF NOT EXISTS idx_solicitacao_material_status
ON solicitacao_material(status);

CREATE INDEX IF NOT EXISTS idx_solicitacao_material_tipo
ON solicitacao_material(tipo_solicitacao);



-- =========================================================
-- ITENS DE SOLICITAÇÃO DE MATERIAL
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_solicitacao_material_item_solicitacao
ON solicitacao_material_item(id_solicitacao);

CREATE INDEX IF NOT EXISTS idx_solicitacao_material_item_produto
ON solicitacao_material_item(id_produto);



-- =========================================================
-- PEDIDOS DE COMPRA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pedido_compra_fabricante
ON pedido_compra(id_fabricante);

CREATE INDEX IF NOT EXISTS idx_pedido_compra_promotor
ON pedido_compra(id_promotor);

CREATE INDEX IF NOT EXISTS idx_pedido_compra_status
ON pedido_compra(status);

CREATE INDEX IF NOT EXISTS idx_pedido_compra_data
ON pedido_compra(data_pedido);

CREATE INDEX IF NOT EXISTS idx_pedido_compra_prevista_disponibilidade
ON pedido_compra(data_prevista_disponibilidade);



-- =========================================================
-- ITENS DOS PEDIDOS DE COMPRA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pedido_compra_item_pedido
ON pedido_compra_item(id_pedido_compra);

CREATE INDEX IF NOT EXISTS idx_pedido_compra_item_produto
ON pedido_compra_item(id_produto);



-- =========================================================
-- RECEBIMENTOS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_recebimento_transportadora
ON recebimento_carga(id_transportadora);

CREATE INDEX IF NOT EXISTS idx_recebimento_motorista
ON recebimento_carga(id_motorista);

CREATE INDEX IF NOT EXISTS idx_recebimento_origem
ON recebimento_carga(id_origem);

CREATE INDEX IF NOT EXISTS idx_recebimento_data_chegada
ON recebimento_carga(data_chegada);

CREATE INDEX IF NOT EXISTS idx_recebimento_data_pagamento_frete
ON recebimento_carga(data_pagamento_frete);

CREATE INDEX IF NOT EXISTS idx_recebimento_transportadora_pagamento
ON recebimento_carga(
    id_transportadora,
    data_pagamento_frete
);



-- =========================================================
-- RECEBIMENTO X PEDIDO DE COMPRA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_recebimento_compra_recebimento
ON recebimento_carga_compra(id_recebimento);

CREATE INDEX IF NOT EXISTS idx_recebimento_compra_pedido
ON recebimento_carga_compra(id_pedido_compra);



-- =========================================================
-- ITENS RECEBIDOS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_recebimento_item_recebimento
ON recebimento_carga_item(id_recebimento);

CREATE INDEX IF NOT EXISTS idx_recebimento_item_produto
ON recebimento_carga_item(id_produto);

CREATE INDEX IF NOT EXISTS idx_recebimento_item_lote
ON recebimento_carga_item(id_lote);



-- =========================================================
-- AGENDAMENTOS DE ENTREGA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_agendamento_entrega_pedido
ON agendamento_entrega(id_pedido);

CREATE INDEX IF NOT EXISTS idx_agendamento_entrega_data
ON agendamento_entrega(data_agendada);

CREATE INDEX IF NOT EXISTS idx_agendamento_entrega_data_periodo
ON agendamento_entrega(data_agendada, periodo);



-- =========================================================
-- ENTREGAS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_entrega_pedido
ON entrega(id_pedido);

CREATE INDEX IF NOT EXISTS idx_entrega_agendamento
ON entrega(id_agendamento);

CREATE INDEX IF NOT EXISTS idx_entrega_transportadora
ON entrega(id_transportadora);

CREATE INDEX IF NOT EXISTS idx_entrega_motorista
ON entrega(id_motorista);

CREATE INDEX IF NOT EXISTS idx_entrega_status
ON entrega(status);

CREATE INDEX IF NOT EXISTS idx_entrega_data_saida

ON entrega(data_saida);

CREATE INDEX IF NOT EXISTS idx_entrega_data_entrega
ON entrega(data_entrega);

CREATE INDEX IF NOT EXISTS idx_entrega_status_data
ON entrega(status, data_entrega);



-- =========================================================
-- ITENS DE ENTREGA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_entrega_item_entrega
ON entrega_item(id_entrega);

CREATE INDEX IF NOT EXISTS idx_entrega_item_pedido_item
ON entrega_item(id_pedido_item);



-- =========================================================
-- JUSTIFICATIVAS DE ENTREGA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_justificativa_entrega_pedido
ON justificativa_entrega(id_pedido);

CREATE INDEX IF NOT EXISTS idx_justificativa_entrega_entrega
ON justificativa_entrega(id_entrega);

CREATE INDEX IF NOT EXISTS idx_justificativa_entrega_tipo
ON justificativa_entrega(tipo);



-- =========================================================
-- PESQUISA NPS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pesquisa_nps_cliente
ON pesquisa_nps(id_cliente);

CREATE INDEX IF NOT EXISTS idx_pesquisa_nps_status
ON pesquisa_nps(status);

CREATE INDEX IF NOT EXISTS idx_pesquisa_nps_data_envio
ON pesquisa_nps(data_envio);



-- =========================================================
-- RESPOSTA NPS
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_resposta_nps_nota
ON resposta_nps(nota);

CREATE INDEX IF NOT EXISTS idx_resposta_nps_data
ON resposta_nps(data_resposta);

CREATE INDEX IF NOT EXISTS idx_resposta_nps_canal
ON resposta_nps(canal_resposta);
