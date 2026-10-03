INSERT INTO classificacao_estoque(nome,descricao)
VALUES
('NORMAL', 'Estoque disponivel para operação normal'),
('SALDO', 'Item com condição comercial diferenciada'),
('RESERVADO CLIENTE', 'Material reservado ou pertencente a pedido de cliente');


INSERT INTO local_estoque(nome, tipo_local)
VALUES
('Loja', 'LOJA'),
('Depósito', 'DEPOSITO')
