/*
JAPDV
*/

SHOW TABLES;

/*
1.
*/
CREATE DATABASE IF NOT EXISTS `japdv`
  CHARACTER SET utf8
  COLLATE utf8_general_ci;

USE `japdv`;

/*
2.
*/

CREATE TABLE IF NOT EXISTS fornecedores (
  idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  fone VARCHAR(20) NOT NULL,
  email VARCHAR(50) NULL
);


INSERT INTO fornecedores (nome, fone, email)
VALUES
 ('Kalunga', '1199999-1111', '[kalunga@kalunga.com.br] (kalunga@kalunga.com.br)'),
 ('Tilibra', '1199999-2222', '[vendas@tilibra.com.br] (vendas@tilibra.com.br)');
 
 /*
 3.
 */
 
 CREATE TABLE IF NOT EXISTS produtos (
  idProduto INT AUTO_INCREMENT PRIMARY KEY,
  codigoBarras VARCHAR(20) UNIQUE NOT NULL,
  descricao VARCHAR(100) NOT NULL,
  categoria VARCHAR(50) NULL,
  precoCusto DECIMAL(10,2) NOT NULL,
  precoVenda DECIMAL(10,2) NOT NULL,
  quantidade INT NOT NULL DEFAULT 0,
  estoqueMinimo INT NOT NULL DEFAULT 0,
  idFornecedor INT NOT NULL,
  CONSTRAINT fk_produtos_fornecedores
    FOREIGN KEY (idFornecedor) REFERENCES fornecedores (idFornecedor)
);


INSERT INTO produtos (codigoBarras, descricao, categoria, precoCusto, precoVenda, quantidade, estoqueMinimo, idFornecedor)
VALUES
('789100000001', 'Caneta BIC Azul',  'Canetas', '1.50', '3.00', '50', '10', '1'),
('789100000002', 'Caneta BIC Vermelha', 'Canetas', '1.60', '3.20', '8', '10', '1'),
('789100000003', 'Caderno Universitário', 'Cadernos', '18.00', '29.90', '0', '5', '2'),
('789100000004', 'Régua 30 cm', 'Réguas', '5.00', '10.00', '15', '5', '1');

/*
4.
*/


CREATE TABLE IF NOT EXISTS vendas (
  idVenda INT AUTO_INCREMENT PRIMARY KEY,
  dataVenda DATETIME DEFAULT NOW(),
  total DECIMAL(10,2) NOT NULL
);

/*
5.
*/


CREATE TABLE IF NOT EXISTS itens_venda (
  idItem INT AUTO_INCREMENT PRIMARY KEY ,
  idVenda INT NOT NULL,
  idProduto INT NOT NULL,
  quantidade INT NOT NULL,
  precoUnitario DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_itens_venda_vendas
    FOREIGN KEY (idVenda) REFERENCES vendas (idVenda)
    ON DELETE CASCADE,
  CONSTRAINT fk_itens_venda_produtos
    FOREIGN KEY (idProduto) REFERENCES produtos (idProduto)
    ON DELETE RESTRICT
);

/*
6.
*/


INSERT INTO vendas (idVenda, total) VALUES 
(1, 16.00);

INSERT INTO itens_venda (idVenda, idProduto, quantidade, precoUnitario)
VALUES
('1', '1', '2', '3.00'),
('1', '4','1', '10.00');


INSERT INTO vendas (idVenda, total) 
VALUES (2, 16.00);

INSERT INTO itens_venda (idVenda, idProduto, quantidade, precoUnitario) 
VALUES
(2, 2, 5, 3.20);

INSERT INTO vendas (idVenda, total)
 VALUES (3, 23.00);
 
INSERT INTO itens_venda (idVenda, idProduto, quantidade, precoUnitario) 
VALUES
(3, 4, 2, 10.00),
(3, 1, 1, 3.00);


SELECT * FROM vendas;

/*
7.
*/

SELECT 
produtos.idProduto,
produtos.descricao,
produtos.categoria,
produtos.precoVenda,
produtos.quantidade,
produtos.estoqueMinimo,
fornecedores.nome
FROM produtos
JOIN fornecedores ON produtos.idFornecedor = fornecedores.idFornecedor
ORDER BY produtos.descricao;


SELECT 
produtos.idProduto,
produtos.codigoBarras,
produtos.descricao,
produtos.categoria,
produtos.quantidade,
produtos.estoqueMinimo,
fornecedores.nome AS fornecedor,
(produtos.estoqueMinimo - produtos.quantidade) AS qtdNecessaria
FROM produtos
JOIN fornecedores ON produtos.idFornecedor = fornecedores.idFornecedor
WHERE produtos.quantidade <= produtos.estoqueMinimo
ORDER BY produtos.quantidade ASC, produtos.descricao ASC;


SELECT 
vendas.idVenda,
DATE_FORMAT(vendas.dataVenda, '%d/%m/%Y %H:%i') AS dataVenda,
produtos.descricao,
itens_venda.quantidade,
itens_venda.precoUnitario,
(itens_venda.quantidade * itens_venda.precoUnitario) AS subtotal
FROM itens_venda
JOIN vendas ON itens_venda.idVenda = vendas.idVenda
JOIN produtos ON itens_venda.idProduto = produtos.idProduto
WHERE vendas.idVenda = 1;

/*
8.
*/

/*
8.1
*/

SELECT COUNT(*) AS total_produtos FROM produtos;

/*
8.2
*/

SELECT COUNT(*) AS baixaQuantidade
FROM produtos 
WHERE quantidade <= estoqueMinimo AND quantidade > 0;

/*
8.3
*/

SELECT COUNT(*) AS sem_estoque
FROM produtos
WHERE quantidade <= 0;

/*
8.4
*/

SELECT COUNT(*) AS VendasHoje
FROM vendas
WHERE DATE(dataVenda) = CURDATE();

/*
8.5
*/

SELECT SUM(itens_venda.quantidade) AS ItensVendidos
FROM itens_venda
INNER JOIN vendas
ON itens_venda.idVenda = vendas.idVenda
WHERE DATE(vendas.dataVenda) = CURDATE();

DESCRIBE vendas;


/*
8.6
*/

SELECT IFNULL(SUM(total), 0) AS resultado_faturamento
FROM vendas
WHERE DATE(dataVenda) = CURDATE();

/*
9
*/

SELECT 
idVenda,
DATE_FORMAT(dataVenda, '%d/%m/%Y %H:%i') AS dataVenda,
total
FROM vendas
ORDER BY datVenda DESC, idVenda DESC
LIMIT 10;



/*
DESAFIO EXTRA
*/


/*
DESAFIO 1
*/
SELECT COUNT(*) AS maiorQuantidade
FROM produtos 
WHERE quantidade > estoqueMinimo AND quantidade > 0;

/*
DESAFIO 2
*/

SELECT 
idProduto, 
descricao, 
precoCusto, 
precoVenda, 
(precoVenda - precoCusto) AS diferenca
FROM produtos
ORDER BY diferenca DESC
LIMIT 1;

/*
DESAFIO 3
*/

SELECT 
  produtos.idProduto,
  produtos.descricao,
  SUM(itens_venda.quantidade) AS total_unidades_vendidas
FROM produtos
LEFT JOIN itens_venda ON produtos.idProduto = itens_venda.idProduto
GROUP BY produtos.idProduto, produtos.descricao;

/*
DESAFIO 4
*/

SELECT 
produtos.idProduto,
produtos.descricao,
SUM(itens_venda.quantidade) AS total_unidades_vendidas
FROM produtos
JOIN itens_venda ON produtos.idProduto = itens_venda.idProduto
GROUP BY produtos.idProduto, produtos.descricao
ORDER BY total_unidades_vendidas DESC
LIMIT 1;

/*
DESAFIO 5
*/

SELECT 
vendas.idVenda,
vendas.total AS total_armazenado,
SUM(itens_venda.quantidade * itens_venda.precoUnitario) AS total_calculado
FROM vendas
JOIN itens_venda ON vendas.idVenda = itens_venda.idVenda
GROUP BY vendas.idVenda, vendas.total;
