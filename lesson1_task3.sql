/*
  Создайте дамп базы данных example из предыдущего задания, 
  разверните содержимое дампа в новую базу данных sample.
*/

DROP DATABASE IF EXISTS sample;
CREATE database sample;

use sample;
source example.sql;



