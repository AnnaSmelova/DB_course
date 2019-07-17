/*
 * 7.1 Создайте двух пользователей которые имеют доступ к базе данных shop. 
 * Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
 * второму пользователю shop — любые операции в пределах базы данных shop.
 */

CREATE USER 'shop_read'@'localhost' IDENTIFIED BY 'user1password';
GRANT SELECT ON shop.* TO 'shop_read'@'localhost';
FLUSH PRIVILEGES;

CREATE USER 'shop'@'localhost' IDENTIFIED BY 'user2password';
GRANT ALL PRIVILEGES ON shop.* TO 'shop'@'localhost';
FLUSH PRIVILEGES;

/*
 * 7.2 (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, 
 * имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
 * Создайте пользователя user_read, который бы не имел доступа к таблице accounts, 
 * однако, мог бы извлекать записи из представления username.
 */

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	`password` VARCHAR(255)
);

INSERT INTO accounts (id, name, `password`) VALUES ('1', 'name1', 'pass1');
INSERT INTO accounts (id, name, `password`) VALUES ('2', 'name2', 'pass2');
INSERT INTO accounts (id, name, `password`) VALUES ('3', 'name3', 'pass3');
INSERT INTO accounts (id, name, `password`) VALUES ('4', 'name4', 'pass4');
INSERT INTO accounts (id, name, `password`) VALUES ('5', 'name5', 'pass5');
INSERT INTO accounts (id, name, `password`) VALUES ('6', 'name6', 'pass6');
INSERT INTO accounts (id, name, `password`) VALUES ('7', 'name7', 'pass7');
INSERT INTO accounts (id, name, `password`) VALUES ('8', 'name8', 'pass8');
INSERT INTO accounts (id, name, `password`) VALUES ('9', 'name9', 'pass9');
INSERT INTO accounts (id, name, `password`) VALUES ('10', 'name10', 'pass10');

CREATE OR REPLACE
VIEW username
AS SELECT
	id,
	name
FROM accounts;

CREATE USER 'user_read'@'localhost' IDENTIFIED BY 'userReadPassword';
GRANT SELECT ON shop.username TO 'user_read'@'localhost';
FLUSH PRIVILEGES;
	
