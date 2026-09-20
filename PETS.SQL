-- ==============================================================================
-- SISTEMA DE GESTÃO INTEGRADA PARA CLÍNICA E PETSHOP (PET CARE)
-- SGBD: MySQL 8.0+
-- Script único contendo: DDL, DML, Consultas (SELECT) e Atualizações (UPDATE)
-- ==============================================================================

DROP DATABASE IF EXISTS db_pet_care;
CREATE DATABASE db_pet_care
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE db_pet_care;

-- ==============================================================================
-- 1. ESTRUTURA DDL (CRIAÇÃO DAS TABELAS)
-- ==============================================================================

-- 1.1. Entidade Genérica: Pessoa
CREATE TABLE TB_PESSOA (
    id_pessoa INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    tipo_pessoa ENUM('CLIENTE', 'FUNCIONARIO') NOT NULL,
    CONSTRAINT chk_pessoa_nome CHECK (CHAR_LENGTH(TRIM(nome)) >= 3)
) ENGINE=InnoDB;

-- 1.2. Decomposição do Atributo Composto: Endereço
CREATE TABLE TB_ENDERECO (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    CONSTRAINT fk_endereco_pessoa
        FOREIGN KEY (id_pessoa)
        REFERENCES TB_PESSOA (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.3. Decomposição do Atributo Multivalorado: Telefone
CREATE TABLE TB_TELEFONE (
    id_telefone INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    numero_telefone VARCHAR(20) NOT NULL,
    tipo ENUM('RESIDENCIAL', 'CELULAR', 'TRABALHO') NOT NULL DEFAULT 'CELULAR',
    CONSTRAINT uq_telefone_pessoa_numero UNIQUE (id_pessoa, numero_telefone),
    CONSTRAINT fk_telefone_pessoa
        FOREIGN KEY (id_pessoa)
        REFERENCES TB_PESSOA (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.4. Especialização: Cliente
CREATE TABLE TB_CLIENTE (
    id_pessoa INT PRIMARY KEY,
    data_cadastro DATE NOT NULL,
    limite_credito DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT chk_cliente_credito CHECK (limite_credito >= 0),
    CONSTRAINT fk_cliente_pessoa
        FOREIGN KEY (id_pessoa)
        REFERENCES TB_PESSOA (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.5. Especialização: Funcionário
CREATE TABLE TB_FUNCIONARIO (
    id_pessoa INT PRIMARY KEY,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    salario DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_funcionario_salario CHECK (salario > 0),
    CONSTRAINT fk_funcionario_pessoa
        FOREIGN KEY (id_pessoa)
        REFERENCES TB_PESSOA (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.6. Especialização de Funcionário: Veterinário
CREATE TABLE TB_VETERINARIO (
    id_pessoa INT PRIMARY KEY,
    crmv VARCHAR(30) NOT NULL UNIQUE,
    CONSTRAINT fk_veterinario_funcionario
        FOREIGN KEY (id_pessoa)
        REFERENCES TB_FUNCIONARIO (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.7. Especialização de Funcionário: Atendente
CREATE TABLE TB_ATENDENTE (
    id_pessoa INT PRIMARY KEY,
    setor VARCHAR(50) NOT NULL DEFAULT 'Atendimento',
    CONSTRAINT fk_atendente_funcionario
        FOREIGN KEY (id_pessoa)
        REFERENCES TB_FUNCIONARIO (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.8. Entidade Forte: Pet
CREATE TABLE TB_PET (
    id_pet INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    especie VARCHAR(30) NOT NULL,
    raca VARCHAR(50) NOT NULL,
    data_nascimento DATE NOT NULL,
    peso DECIMAL(5,2) NOT NULL,
    CONSTRAINT chk_pet_peso CHECK (peso > 0),
    CONSTRAINT fk_pet_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES TB_CLIENTE (id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.9. Entidade Fraca: Prontuário (Chave composta: id_pet, numero_prontuario)
CREATE TABLE TB_PRONTUARIO (
    id_pet INT NOT NULL,
    numero_prontuario INT NOT NULL,
    data_atendimento DATETIME NOT NULL,
    diagnostico TEXT NOT NULL,
    prescricao TEXT NOT NULL,
    PRIMARY KEY (id_pet, numero_prontuario),
    CONSTRAINT chk_prontuario_numero CHECK (numero_prontuario > 0),
    CONSTRAINT fk_prontuario_pet
        FOREIGN KEY (id_pet)
        REFERENCES TB_PET (id_pet)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.10. Entidade Forte: Sala de Procedimento
CREATE TABLE TB_SALA_PROCEDIMENTO (
    id_sala INT AUTO_INCREMENT PRIMARY KEY,
    numero_sala VARCHAR(10) NOT NULL UNIQUE,
    bloco VARCHAR(30) NOT NULL,
    status_sala ENUM('DISPONIVEL', 'OCUPADA', 'MANUTENCAO') NOT NULL DEFAULT 'DISPONIVEL'
) ENGINE=InnoDB;

-- 1.11. Relacionamento Ternário: Atendimento (Veterinário, Pet e Sala)
CREATE TABLE TB_ATENDIMENTO (
    id_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    id_vet INT NOT NULL,
    id_pet INT NOT NULL,
    id_sala INT NOT NULL,
    data_hora_atendimento DATETIME NOT NULL,
    observacoes TEXT,
    CONSTRAINT fk_atendimento_veterinario
        FOREIGN KEY (id_vet)
        REFERENCES TB_VETERINARIO (id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_atendimento_pet
        FOREIGN KEY (id_pet)
        REFERENCES TB_PET (id_pet)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_atendimento_sala
        FOREIGN KEY (id_sala)
        REFERENCES TB_SALA_PROCEDIMENTO (id_sala)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.12. Entidade Forte: Produto
CREATE TABLE TB_PRODUTO (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    categoria ENUM('RACAO', 'HIGIENE', 'MEDICAMENTO', 'ACESSORIO', 'OUTROS') NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    qtd_estoque INT NOT NULL,
    CONSTRAINT chk_produto_preco CHECK (preco_unitario >= 0),
    CONSTRAINT chk_produto_estoque CHECK (qtd_estoque >= 0)
) ENGINE=InnoDB;

-- 1.13. Entidade Forte: Venda
CREATE TABLE TB_VENDA (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_atendente INT NOT NULL,
    data_venda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    forma_pagamento ENUM('DINHEIRO', 'PIX', 'DEBITO', 'CREDITO', 'BOLETO') NOT NULL,
    CONSTRAINT chk_venda_total CHECK (valor_total >= 0),
    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES TB_CLIENTE (id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_venda_atendente
        FOREIGN KEY (id_atendente)
        REFERENCES TB_ATENDENTE (id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.14. Entidade Associativa (M:N): Item de Venda
CREATE TABLE TB_ITEM_VENDA (
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario_praticado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_venda, id_produto),
    CONSTRAINT chk_item_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_item_preco CHECK (preco_unitario_praticado >= 0),
    CONSTRAINT fk_item_venda
        FOREIGN KEY (id_venda)
        REFERENCES TB_VENDA (id_venda)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES TB_PRODUTO (id_produto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- ==============================================================================
-- 2. INSERÇÃO DE DADOS (POPULAÇÃO DO BANCO - MÍNIMO DE 5 REGISTROS POR TABELA)
-- ==============================================================================

INSERT INTO TB_PESSOA (id_pessoa, nome, cpf, tipo_pessoa) VALUES
(1, 'Carlos Silva', '111.222.333-44', 'CLIENTE'),
(2, 'Ana Oliveira', '222.333.444-55', 'CLIENTE'),
(3, 'Marcos Souza', '333.444.555-66', 'CLIENTE'),
(4, 'Fernanda Lima', '444.555.666-77', 'CLIENTE'),
(5, 'Roberto Rocha', '555.666.777-88', 'CLIENTE'),
(6, 'Dra. Camila Alves', '666.777.888-99', 'FUNCIONARIO'),
(7, 'Dr. Juliano Costa', '777.888.999-00', 'FUNCIONARIO'),
(8, 'Beatriz Santos', '888.999.000-11', 'FUNCIONARIO'),
(9, 'Lucas Mendes', '999.000.111-22', 'FUNCIONARIO'),
(10, 'Mariana Dias', '000.111.222-33', 'FUNCIONARIO'),
(11, 'Patricia Nunes', '123.456.789-01', 'FUNCIONARIO'),
(12, 'Diego Ramos', '234.567.890-12', 'FUNCIONARIO'),
(13, 'Juliana Prado', '345.678.901-23', 'FUNCIONARIO'),
(14, 'Eduardo Farias', '456.789.012-34', 'FUNCIONARIO'),
(15, 'Renata Alves', '567.890.123-45', 'FUNCIONARIO');

INSERT INTO TB_ENDERECO (id_pessoa, logradouro, numero, bairro, cidade, cep) VALUES
(1, 'Rua das Flores', '100', 'Centro', 'Sao Paulo', '01001-000'),
(2, 'Av. Paulista', '1500', 'Bela Vista', 'Sao Paulo', '01310-100'),
(3, 'Rua Augusta', '450', 'Consolacao', 'Sao Paulo', '01305-000'),
(4, 'Rua Amazonas', '88', 'Pituba', 'Salvador', '41830-000'),
(5, 'Av. Brasil', '2000', 'Funcionarios', 'Belo Horizonte', '30140-000');

INSERT INTO TB_TELEFONE (id_pessoa, numero_telefone, tipo) VALUES
(1, '(11) 98888-1111', 'CELULAR'),
(2, '(11) 97777-2222', 'CELULAR'),
(3, '(11) 3222-3333', 'RESIDENCIAL'),
(4, '(71) 99999-4444', 'CELULAR'),
(5, '(31) 98888-5555', 'CELULAR'),
(6, '(11) 96666-1111', 'CELULAR'),
(7, '(11) 96666-2222', 'CELULAR'),
(8, '(11) 96666-3333', 'TRABALHO'),
(9, '(11) 96666-4444', 'TRABALHO'),
(10, '(11) 96666-5555', 'TRABALHO'),
(11, '(11) 95555-1111', 'TRABALHO'),
(12, '(11) 95555-2222', 'TRABALHO'),
(13, '(11) 95555-3333', 'TRABALHO'),
(14, '(11) 95555-4444', 'TRABALHO'),
(15, '(11) 95555-5555', 'TRABALHO');

INSERT INTO TB_CLIENTE (id_pessoa, data_cadastro, limite_credito) VALUES
(1, '2023-01-10', 500.00),
(2, '2023-02-15', 1000.00),
(3, '2023-03-20', 300.00),
(4, '2023-04-12', 1500.00),
(5, '2023-05-05', 800.00);

INSERT INTO TB_FUNCIONARIO (id_pessoa, matricula, salario) VALUES
(6, 'FUNC-001', 8500.00),
(7, 'FUNC-002', 9200.00),
(8, 'FUNC-003', 3200.00),
(9, 'FUNC-004', 3100.00),
(10, 'FUNC-005', 3300.00),
(11, 'FUNC-006', 3000.00),
(12, 'FUNC-007', 3050.00),
(13, 'FUNC-008', 3100.00),
(14, 'FUNC-009', 3150.00),
(15, 'FUNC-010', 3200.00);

-- Especialização disjunta: cada funcionário é OU veterinário OU atendente (nunca os dois).
-- Veterinários (id 6-10) e atendentes (id 11-15) são conjuntos de pessoas totalmente distintos.
INSERT INTO TB_VETERINARIO (id_pessoa, crmv) VALUES
(6, 'CRMV-SP-12345'),
(7, 'CRMV-SP-67890'),
(8, 'CRMV-SP-54321'),
(9, 'CRMV-SP-98765'),
(10, 'CRMV-SP-24680');

INSERT INTO TB_ATENDENTE (id_pessoa, setor) VALUES
(11, 'Caixa'),
(12, 'Caixa'),
(13, 'Recepcao'),
(14, 'Atendimento'),
(15, 'Atendimento');

INSERT INTO TB_PET (id_cliente, nome, especie, raca, data_nascimento, peso) VALUES
(1, 'Rex', 'Cao', 'Pastor Alemao', '2020-05-10', 32.50),
(2, 'Miau', 'Gato', 'Siames', '2021-08-14', 4.20),
(3, 'Thor', 'Cao', 'Bulldog', '2019-11-30', 22.00),
(4, 'Mel', 'Cao', 'Poodle', '2022-02-01', 6.10),
(5, 'Fifi', 'Gato', 'Persa', '2020-01-20', 3.80);

INSERT INTO TB_PRONTUARIO (id_pet, numero_prontuario, data_atendimento, diagnostico, prescricao) VALUES
(1, 1, '2024-01-15 10:00:00', 'Exame de rotina e vacinacao', 'Vacina antirrabica aplicada'),
(2, 1, '2024-01-16 11:30:00', 'Gastroenterite leve', 'Administrar probiotico por 5 dias'),
(3, 1, '2024-01-18 14:00:00', 'Limpeza de tartaro', 'Agendado procedimento de tartarectomia'),
(4, 1, '2024-01-20 09:15:00', 'Otite bilateral', 'Ceruminol e anti-inflamatorio em gotas'),
(5, 1, '2024-01-22 16:45:00', 'Dermatite atopica', 'Shampoo terapeutico hipoalergenico');

INSERT INTO TB_SALA_PROCEDIMENTO (numero_sala, bloco, status_sala) VALUES
('Sala 101', 'Bloco A', 'DISPONIVEL'),
('Sala 102', 'Bloco A', 'DISPONIVEL'),
('Centro 01', 'Bloco Cirurgico', 'DISPONIVEL'),
('Centro 02', 'Bloco Cirurgico', 'OCUPADA'),
('Sala 103', 'Bloco B', 'MANUTENCAO');

INSERT INTO TB_ATENDIMENTO (id_vet, id_pet, id_sala, data_hora_atendimento, observacoes) VALUES
(6, 1, 1, '2024-02-01 09:00:00', 'Atendimento de rotina sem intercorrencias'),
(7, 2, 2, '2024-02-01 10:30:00', 'Gato apresentou estresse moderado'),
(6, 3, 3, '2024-02-02 14:00:00', 'Procedimento de tartarectomia bem sucedido'),
(7, 4, 1, '2024-02-03 11:00:00', 'Retorno de consulta otologica'),
(6, 5, 2, '2024-02-04 15:30:00', 'Avaliacao dermatologica completa');

INSERT INTO TB_PRODUTO (nome_produto, categoria, preco_unitario, qtd_estoque) VALUES
('Racao Premium Caes 15kg', 'RACAO', 189.90, 50),
('Shampoo Antipulgas 500ml', 'HIGIENE', 35.50, 100),
('Vermifugo Plus 4 comprimidos', 'MEDICAMENTO', 45.00, 200),
('Coleira Antipulgas', 'ACESSORIO', 89.90, 30),
('Racao Gatos Castrados 10kg', 'RACAO', 165.00, 40);

INSERT INTO TB_VENDA (id_cliente, id_atendente, data_venda, valor_total, forma_pagamento) VALUES
(1, 11, '2024-02-01 10:00:00', 225.40, 'PIX'),
(2, 11, '2024-02-01 11:45:00', 165.00, 'CREDITO'),
(3, 12, '2024-02-02 15:00:00', 89.90, 'DEBITO'),
(4, 12, '2024-02-03 12:00:00', 279.80, 'PIX'),
(5, 13, '2024-02-04 16:30:00', 45.00, 'DINHEIRO');

INSERT INTO TB_ITEM_VENDA (id_venda, id_produto, quantidade, preco_unitario_praticado) VALUES
(1, 1, 1, 189.90),
(1, 2, 1, 35.50),
(2, 5, 1, 165.00),
(3, 4, 1, 89.90),
(4, 1, 1, 189.90),
(4, 4, 1, 89.90),
(5, 3, 1, 45.00);


-- ==============================================================================
-- 3. SCRIPTS DE MANIPULAÇÃO DE DADOS: CONSULTAS (SELECT)
-- ==============================================================================

-- 3.1. Relatório do Relacionamento Ternário (Atendimento, Veterinário, Pet, Cliente, Sala)
SELECT 
    A.id_atendimento,
    A.data_hora_atendimento,
    PV.nome AS veterinario,
    PC.nome AS cliente,
    P.nome AS pet,
    S.numero_sala AS sala,
    A.observacoes
FROM TB_ATENDIMENTO A
INNER JOIN TB_VETERINARIO V ON A.id_vet = V.id_pessoa
INNER JOIN TB_PESSOA PV ON V.id_pessoa = PV.id_pessoa
INNER JOIN TB_PET P ON A.id_pet = P.id_pet
INNER JOIN TB_CLIENTE C ON P.id_cliente = C.id_pessoa
INNER JOIN TB_PESSOA PC ON C.id_pessoa = PC.id_pessoa
INNER JOIN TB_SALA_PROCEDIMENTO S ON A.id_sala = S.id_sala
ORDER BY A.data_hora_atendimento;

-- 3.2. Total Gasto por Cliente (com GROUP BY e HAVING > R$100,00)
SELECT 
    PC.nome AS cliente,
    COUNT(V.id_venda) AS qtd_vendas,
    SUM(V.valor_total) AS total_gasto
FROM TB_CLIENTE C
INNER JOIN TB_PESSOA PC ON C.id_pessoa = PC.id_pessoa
INNER JOIN TB_VENDA V ON C.id_pessoa = V.id_cliente
GROUP BY C.id_pessoa, PC.nome
HAVING SUM(V.valor_total) > 100.00
ORDER BY total_gasto DESC;

-- 3.3. Pets e Situação de Prontuário (Utilizando LEFT JOIN)
SELECT 
    P.nome AS pet,
    P.especie,
    PC.nome AS proprietario,
    CASE 
        WHEN PR.id_pet IS NULL THEN 'SEM PRONTUARIO'
        ELSE 'COM PRONTUARIO'
    END AS situacao_prontuario
FROM TB_PET P
INNER JOIN TB_PESSOA PC ON P.id_cliente = PC.id_pessoa
LEFT JOIN (SELECT DISTINCT id_pet FROM TB_PRONTUARIO) PR ON P.id_pet = PR.id_pet
ORDER BY P.nome;

-- 3.4. Vendas, Itens, Produtos e Atendentes
SELECT 
    V.id_venda,
    V.data_venda,
    PR.nome_produto,
    PA.nome AS atendente,
    IV.quantidade,
    IV.preco_unitario_praticado,
    (IV.quantidade * IV.preco_unitario_praticado) AS subtotal
FROM TB_VENDA V
INNER JOIN TB_ATENDENTE A ON V.id_atendente = A.id_pessoa
INNER JOIN TB_PESSOA PA ON A.id_pessoa = PA.id_pessoa
INNER JOIN TB_ITEM_VENDA IV ON V.id_venda = IV.id_venda
INNER JOIN TB_PRODUTO PR ON IV.id_produto = PR.id_produto
ORDER BY V.id_venda, PR.nome_produto;

-- 3.5. Quantidade de Pets por Cliente
SELECT 
    PC.nome AS cliente,
    COUNT(P.id_pet) AS total_pets
FROM TB_CLIENTE C
INNER JOIN TB_PESSOA PC ON C.id_pessoa = PC.id_pessoa
LEFT JOIN TB_PET P ON C.id_pessoa = P.id_cliente
GROUP BY C.id_pessoa, PC.nome
ORDER BY total_pets DESC, cliente;

-- 3.6. Produtos com Estoque Abaixo da Média (Subconsulta)
SELECT 
    nome_produto,
    categoria,
    qtd_estoque
FROM TB_PRODUTO
WHERE qtd_estoque < (SELECT AVG(qtd_estoque) FROM TB_PRODUTO)
ORDER BY qtd_estoque;

-- 3.7. Conferência de Consistência do Total Calculado vs Registrado nas Vendas
SELECT 
    V.id_venda,
    V.valor_total AS total_registrado,
    SUM(IV.quantidade * IV.preco_unitario_praticado) AS total_calculado
FROM TB_VENDA V
INNER JOIN TB_ITEM_VENDA IV ON V.id_venda = IV.id_venda
GROUP BY V.id_venda, V.valor_total;


-- ==============================================================================
-- 4. SCRIPTS DE MANIPULAÇÃO DE DADOS: ATUALIZAÇÕES (UPDATE)
-- ==============================================================================

-- 4.1. Reajuste de 10% no preço dos produtos com estoque abaixo de 50 unidades
UPDATE TB_PRODUTO
SET preco_unitario = ROUND(preco_unitario * 1.10, 2)
WHERE qtd_estoque < 50;

-- 4.2. Atualização do peso do Pet id_pet = 1 após nova avaliação clínica
UPDATE TB_PET
SET peso = 33.80
WHERE id_pet = 1;

-- 4.3. Alteração do status da Sala de Procedimento id_sala = 4 para DISPONIVEL
UPDATE TB_SALA_PROCEDIMENTO
SET status_sala = 'DISPONIVEL'
WHERE id_sala = 4;
