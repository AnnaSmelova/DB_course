USE shop;

/*
 * 6.1 В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
 * Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. 
 * Используйте транзакции.
 */
 
START TRANSACTION;

INSERT INTO 
	sample.users (id, name, birthday_at, created_at, updated_at)  
SELECT 
	id, 
	name, 
	birthday_at, 
	created_at, 
	updated_at 
FROM shop.users 
WHERE id = 1;

DELETE FROM shop.users
WHERE id = 1;

COMMIT;

/*
 * 6.2 Создайте представление, которое выводит название name товарной позиции из таблицы products 
 * и соответствующее название каталога name из таблицы catalogs.
 */

CREATE OR REPLACE
VIEW products_cat
AS SELECT 
	p.name AS name,
	c.name AS catalog_position
FROM products AS p
INNER JOIN catalogs AS c
ON p.catalog_id = c.id;

SELECT * FROM products_cat;

/*
 * 6.3 (по желанию) Пусть имеется таблица с календарным полем created_at. 
 * В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
 * Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
 * если дата присутствует в исходном таблице и 0, если она отсутствует.
 */

/*
 * Создаем таблицу task_6_3, в которую записываем данные в задаче даты
 * Формируем таблицу nums, в которую записываем 31 число - от 0 до 30 (по идее, можно было бы использовать любую таблицу, 
 * где более 31 строки, но так надежнее
 * Формируем временную таблицу august_dates (таблица nums формируется в подселекте этой временной таблицы),
 * в ней содержаться даты на каждый день августа 2018 года
 * Соединяем таблицы august_dates и task_6_3 по ключу равенство указанных дат
 * LEFT JOIN используем, т.к. нам нужны все записи из таблицы august_dates
 */

DROP TABLE IF EXISTS task_6_3;
CREATE TABLE task_6_3 (
	id SERIAL PRIMARY KEY,
	created_at DATE
);

INSERT INTO task_6_3 (id, created_at) VALUES ('1', '2018-08-01');
INSERT INTO task_6_3 (id, created_at) VALUES ('2', '2018-08-04');
INSERT INTO task_6_3 (id, created_at) VALUES ('3', '2018-08-16');
INSERT INTO task_6_3 (id, created_at) VALUES ('4', '2018-08-17');


SET @i = -1;
CREATE TEMPORARY TABLE august_dates AS
	(SELECT 
		DATE_ADD( '2018-08-01', interval @i := @i+1 day) AS date_sequence
	FROM
		(SELECT 
			CAST(CONCAT(CAST(t1.num AS CHAR), CAST(t2.num AS CHAR)) AS UNSIGNED) AS num
		FROM
			(SELECT 0 AS num UNION SELECT 1 UNION SELECT 2 UNION SELECT 3) t1
		CROSS JOIN
			(SELECT 0 AS num UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
			UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 ) t2
		ORDER BY num
		LIMIT 31
		) AS nums
	HAVING DATE_ADD('2018-08-01', interval @i day) <= '2018-08-31');

SELECT
	august_dates.date_sequence AS `date`,
	COUNT(t.created_at) AS `attend/miss`
FROM august_dates
LEFT JOIN task_6_3 AS t
ON august_dates.date_sequence = t.created_at
GROUP BY august_dates.date_sequence
ORDER BY august_dates.date_sequence;

/*
 * 6.4 (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
 * Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
 */

/*
 * В таблице orders много записей, и есть поле created_at, поэтому будем портить ее
 * Формируем временную таблицу top_5_actual_records_id, в которую записываем 5 первых id 
 * из отсортированных по дате в порядке убывания записей в таблице orders
 * Затем удаляем из таблицы orders все записи, id которых не совпадают с id из временной таблицы
 */

CREATE TEMPORARY TABLE top_5_actual_records_id AS
	(SELECT 
		id
	FROM orders
	ORDER BY created_at DESC
	LIMIT 5);

DELETE FROM orders
WHERE id NOT IN
	(SELECT * FROM top_5_actual_records_id);
