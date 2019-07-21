USE shop;

/*
 * 8.1
 * Создайте хранимую функцию hello(), которая будет возвращать приветствие, 
 * в зависимости от текущего времени суток. 
 * С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
 * с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
 * с 18:00 до 00:00 — "Добрый вечер", 
 * с 00:00 до 6:00 — "Доброй ночи".
*/

DROP FUNCTION IF EXISTS hello;
DELIMITER //
CREATE FUNCTION hello()
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
	DECLARE hours INT;
	DECLARE sresult VARCHAR(255);
	SET hours = HOUR(NOW());
	IF(6 <= hours AND hours <= 11) THEN
		SET sresult = "Доброе утро";
	ELSEIF(12 <= hours AND hours <= 17) THEN
		SET sresult = "Добрый день";
	ELSEIF(18 <= hours AND hours <= 23) THEN
		SET sresult = "Добрый вечер";
	ELSE
		SET sresult = "Доброй ночи";
	END IF;
	RETURN sresult;
END//
DELIMITER ;

-- Проверяем работу функции
SELECT hello();

/*
 * 8.2
 * В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
 * Допустимо присутствие обоих полей или одно из них. 
 * Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
 * Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
 * При попытке присвоить полям NULL-значение необходимо отменить операцию.
*/

-- В моей базе shop поле "description" называется "desription" - так было с самого начала в примере с урока

-- Триггер на отмену добавления записи в случае, если не заполнены оба поля
DROP TRIGGER IF EXISTS products_b_i_desc;
DELIMITER //
CREATE TRIGGER products_b_i_desc BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	IF(NEW.name IS NULL AND NEW.desription IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Необходимо указать наименование и описание продукта. Добавление отменено.';
	END IF;
END//
DELIMITER ;

-- Триггер на отмену обновления записи в случае, если стираются оба поля
DROP TRIGGER IF EXISTS products_b_u_desc;
DELIMITER //
CREATE TRIGGER products_b_u_desc BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	IF(NEW.name IS NULL AND NEW.desription IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Наименование и описание продукта не могут быть пустыми. Обновление отменено.';
	END IF;
END//
DELIMITER ;

-- Проверяем работу триггера на добавление
INSERT INTO products (name, desription, price, catalog_id) VALUES (NULL, NULL, 123.45, 6);
INSERT INTO products (name, desription, price, catalog_id) VALUES (NULL, 'desription', 123.45, 6);
SELECT * FROM products;

-- Проверяем работу триггера на обновление
UPDATE products SET name = NULL, desription = NULL WHERE id = 4;

/*
 * 8.3
 * (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
 * Числами Фибоначчи называется последовательность 
 * в которой число равно сумме двух предыдущих чисел. 
 * Вызов функции FIBONACCI(10) должен возвращать число 55.
*/

DROP FUNCTION IF EXISTS FIBONACCI;
DELIMITER //
CREATE FUNCTION FIBONACCI(num INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE f0, f1, fn, i INT;
	SET i = 2;
	SET f0 = 0;
	SET f1 = 1;
	SET fn = 1;
	IF(num = 0) THEN
		SET fn = f0;
	ELSEIF(num = 1) THEN
		SET fn = f1;
	ELSE
		WHILE i <= num DO
			SET fn = f0 + f1;
			SET f0 = f1;
			SET f1 = fn;
			SET i = i + 1;
		END WHILE;
	END IF;
	RETURN fn;
END//
DELIMITER ;

-- Проверяем работу функции
SELECT FIBONACCI(0);
SELECT FIBONACCI(1);
SELECT FIBONACCI(7);
SELECT FIBONACCI(10);
