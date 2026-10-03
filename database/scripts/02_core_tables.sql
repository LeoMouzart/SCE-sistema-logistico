-- SCE - Sistema de Controle de Estoque e Logística
-- Arquivo: 02_core_tables.sql
-- Objetivo: criar tabelas-base do sistema


-- CLIENTE

CREATE TABLE cliente (
    id_cliente BIGSERIAL PRIMARY KEY,
    nome_razao_social VARCHAR(150) NOT NULL,
    nome_fantasia VARCHAR(150),
    cpf_cnpj VARCHAR(20),
    telefone VARCHAR(30),
    email VARCHAR(150),
    cidade VARCHAR(100),
    estado CHAR(2),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- VENDEDOR

CREATE TABLE vendedor (
    id_vendedor BIGSERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    telefone VARCHAR(30),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- CATEGORIA

CREATE TABLE categoria (
    id_categoria BIGSERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(255),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- FABRICANTE

CREATE TABLE fabricante (
    id_fabricante BIGSERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL UNIQUE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- PRODUTO

CREATE TABLE produto (
    id_produto BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(200) NOT NULL,
    id_categoria BIGINT NOT NULL,
    id_fabricante BIGINT,
    unidade_medida VARCHAR(20) NOT NULL,
    estoque_minimo NUMERIC(12,3) NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categoria(id_categoria),

    CONSTRAINT fk_produto_fabricante
        FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante),

    CONSTRAINT chk_produto_estoque_minimo
        CHECK (estoque_minimo >= 0)
);


-- ORIGEM DO MATERIAL

CREATE TABLE origem_material (
    id_origem BIGSERIAL PRIMARY KEY,
    tipo_origem VARCHAR(30) NOT NULL,
    nome VARCHAR(150) NOT NULL,
    cidade VARCHAR(100),
    estado CHAR(2),
    observacao TEXT,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_origem_tipo
        CHECK (
            tipo_origem IN (
                'FABRICA',
                'LOJA_TERCEIRA',
                'OUTROS'
            )
        )
);


-- TRANSPORTADORA

CREATE TABLE transportadora (
    id_transportadora BIGSERIAL PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    nome_fantasia VARCHAR(150),
    cnpj VARCHAR(20),
    telefone VARCHAR(30),
    email VARCHAR(150),
    contato VARCHAR(150),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- MOTORISTA

CREATE TABLE motorista (
    id_motorista BIGSERIAL PRIMARY KEY,
    id_transportadora BIGINT,
    nome VARCHAR(150) NOT NULL,
    cpf VARCHAR(20),
    telefone VARCHAR(30),
    cnh VARCHAR(30),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_motorista_transportadora
        FOREIGN KEY (id_transportadora)
        REFERENCES transportadora(id_transportadora)
);


-- VEICULO

CREATE TABLE veiculo (
    id_veiculo BIGSERIAL PRIMARY KEY,
    id_transportadora BIGINT,
    placa VARCHAR(10) NOT NULL UNIQUE,
    modelo VARCHAR(100),
    capacidade_m2 NUMERIC(12,3),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_veiculo_transportadora
        FOREIGN KEY (id_transportadora)
        REFERENCES transportadora(id_transportadora),

    CONSTRAINT chk_veiculo_capacidade
        CHECK (
            capacidade_m2 IS NULL
            OR capacidade_m2 >= 0
        )
);


-- USUARIO

CREATE TABLE usuario (
    id_usuario BIGSERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    login VARCHAR(100) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    email VARCHAR(150),
    perfil VARCHAR(30) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_usuario_perfil
        CHECK (
            perfil IN (
                'ADMIN',
                'GESTAO',
                'EXPEDICAO',
                'VENDEDOR'
            )
        )
);


-- LOCALIZACAO FISICA DO PRODUTO

CREATE TABLE local_estoque (
    id_local BIGSERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_local VARCHAR(20) NOT NULL,
    descricao VARCHAR(255),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_local_tipo
        CHECK (
            tipo_local IN (
                'LOJA',
                'DEPOSITO',
                'EM_TRANSITO'
            )
        )
);


-- SITUACAO / CLASSIFICACAO DO ESTOQUE

CREATE TABLE classificacao_estoque (
    id_classificacao BIGSERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(255),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
