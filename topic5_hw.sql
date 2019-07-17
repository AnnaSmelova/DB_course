USE shop;

/*
 * 5.1 Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
 */

SELECT 
	name
FROM
	users
WHERE 
	id IN (SELECT DISTINCT user_id FROM orders)
ORDER by name;

/*
 * 5.2 Выведите список товаров products и разделов catalogs, который соответствует товару.
 */

SELECT
	pr.name AS product_name,
	ca.name AS catalog_item_name
FROM
	products AS pr
INNER JOIN catalogs AS ca
ON pr.catalog_id = ca.id
ORDER BY ca.name, pr.name;
  
/*
 * 5.3 (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
 * Поля from, to и label содержат английские названия городов, поле name — русское. 
 * Выведите список рейсов flights с русскими названиями городов.
 */

SELECT 
	fl.id,
	ci1.name AS `from`,
	ci2.name AS `to`
FROM 
	flights AS fl 
INNER JOIN cities AS ci1 
ON fl.`from` = ci1.label
INNER JOIN cities AS ci2
ON fl.`to` = ci2.label;
