/*
 Создайте базу данных example, 
 разместите в ней таблицу users, 
 состоящую из двух столбцов, 
 числового id и строкового name.
 */

DROP DATABASE IF EXISTS example;
CREATE database example;

use example;
DROP TABLE IF EXISTS users;
CREATE TABLE users (id INT, name VARCHAR(20));
