# Sistema de Gestão Integrada para Clínica e Petshop — Pet Care


* Projeto acadêmico de Modelagem e Implementação de Banco de Dados Relacional para uma clínica veterinária integrada a um petshop. O sistema centraliza clientes, pets, funcionários (veterinários e atendentes), prontuários, salas de procedimento, produtos, vendas e itens de venda em um único banco de dados normalizado. *

## Tecnologias
MySQL 8.0+

MySQL Workbench

Mermaid.js

Git e GitHub

Funcionalidades modeladas

Cadastro de pessoas (clientes e funcionários)

Especialização de funcionários em veterinários e atendentes

Endereços (atributo composto) e telefones (atributo multivalorado)

Cadastro de pets e prontuários (entidade fraca)

Salas de procedimento e atendimento veterinário (relacionamento ternário)

Produtos, controle de estoque e formas de pagamento

Vendas e itens de venda (entidade associativa M:N)

Consultas SQL avançadas e atualizações (UPDATE)

## Estrutura do projeto

PETS.SQL — script SQL único com DDL, DML, consultas (SELECT) e atualizações (UPDATE)

README.md — este arquivo

## Execução
Abrir PETS.SQL no MySQL Workbench (ou outro cliente MySQL 8.0+).
Executar o script completo.
O banco db_pet_care será criado automaticamente.
As tabelas serão criadas respeitando a ordem de dependência das chaves estrangeiras.
Os registros de demonstração serão inseridos (mínimo de 5 por tabela).
As consultas SELECT (seção 3 do script) podem ser executadas para validação.
Os UPDATEs (seção 4 do script) demonstram operações do cotidiano do sistema.

## Modelagem

* O projeto contempla:

Entidades fortes (Pet, Produto, Venda, Sala de Procedimento);

Entidade fraca (Prontuário, com chave composta id_pet + numero_prontuario);

Entidade associativa (Item_Venda, resolvendo o M:N entre Venda e Produto);

Generalização/especialização (Pessoa → Cliente/Funcionário; Funcionário → Veterinário/Atendente);

Relacionamento 1:1 (especializações);

Relacionamento 1:N (Cliente–Pet, Pet–Prontuário, Cliente–Venda, Atendente–Venda);

Relacionamento M:N (Venda–Produto via Item_Venda);

Relacionamento ternário (Veterinário–Pet–Sala, via Atendimento);

Atributo composto (Endereço) e atributo multivalorado (Telefones);

Chaves primárias, estrangeiras e compostas;
Normalização em 1FN, 2FN e 3FN.



## Integrantes
* Guilherme Alves Rocha — Engenharia de Software
*  Disciplina - Modelagem de Banco de Dados
