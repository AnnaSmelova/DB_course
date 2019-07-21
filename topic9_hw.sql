/*
 * 9.1
 * Создайте таблицу logs типа Archive. 
 * Пусть при каждом создании записи в таблицах users, catalogs и products 
 * в таблицу logs помещается время и дата создания записи, 
 * название таблицы, идентификатор первичного ключа и содержимое поля name.
*/

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  name_table VARCHAR(255) COMMENT 'Название таблицы',
  created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время и дата создания записи',
  table_id INT COMMENT 'идентификатор первичного ключа таблицы',
  table_name VARCHAR(255) COMMENT 'содержимое поля name таблицы'
) COMMENT = 'users, catalogs and products logs' ENGINE=Archive;

-- Триггер: логгирование добавления записи в таблицу users
DROP TRIGGER IF EXISTS users_a_i_logging;
DELIMITER //
CREATE TRIGGER users_a_i_logging AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs 
		(name_table, created_time, table_id, table_name)
	VALUES
		('users', NEW.created_at, NEW.id, NEW.name);
END//
DELIMITER ;

-- Триггер: логгирование добавления записи в таблицу catalogs
DROP TRIGGER IF EXISTS catalogs_a_i_logging;
DELIMITER //
CREATE TRIGGER catalogs_a_i_logging AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs 
		(name_table, table_id, table_name)
	VALUES
		('catalogs', NEW.id, NEW.name);
END//
DELIMITER ;

-- Триггер: логгирование добавления записи в таблицу products
DROP TRIGGER IF EXISTS products_a_i_logging;
DELIMITER //
CREATE TRIGGER products_a_i_logging AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs 
		(name_table, created_time, table_id, table_name)
	VALUES
		('products', NEW.created_at, NEW.id, NEW.name);
END//
DELIMITER ;

-- Проверяем работу логики
INSERT INTO users (name, birthday_at) VALUES ('Name1', '1991-10-05');
INSERT INTO catalogs (name) VALUES ('Cat1');
INSERT INTO products (name, desription, price, catalog_id) VALUES ('Pr1', 'Pr1_desc', 123.00, 1);

SELECT * FROM logs;
SELECT COUNT(*) FROM logs;

/*
 * 9.2
 * (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
 */

-- Для более быстрого добавления данных в таблицу разбиваем на 1000 транзакций по 1000 операций
-- Когда отключила логгирование таблицы users из предыдущего задания, - стало отрабатывать за 1 минуту и 15 секунд

DELIMITER //
DROP PROCEDURE IF EXISTS insert_1kk_users//
CREATE PROCEDURE insert_1kk_users()
BEGIN
	DECLARE n, i, k INT;
	DECLARE name VARCHAR(255);
	DECLARE birthday DATE;
	SET n = 0;
	SET k = 1;
	WHILE n < 1000 DO
		START TRANSACTION;
		SET i = 1;
		SET name = CONCAT('User',' ', k);
		SET birthday = '1970-01-01';
		WHILE i <= 1000 DO
			INSERT INTO users (name, birthday_at) VALUES (name, birthday);
			SET i = i + 1;
			SET k = k + 1;
			SET name = CONCAT('User',' ', k);
			SET birthday = DATE_ADD(birthday, INTERVAL 1 DAY);
		END WHILE;
		COMMIT;
		SET n = n + 1;
	END WHILE;
END//
DELIMITER ;

-- Запускаем процедуру
CALL insert_1kk_users;

-- Проверяем результат
SELECT * FROM users ORDER BY id DESC LIMIT 10;
SELECT COUNT(*) FROM users;
