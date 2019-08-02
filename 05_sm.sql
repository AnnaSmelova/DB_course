USE sm;


-- TEST DATA


SELECT * FROM record_types;
SELECT * FROM statuses;
SELECT * FROM priorities;
SELECT * FROM closure_codes;
SELECT * FROM userroles;
SELECT * FROM positions;
SELECT * FROM depts;
SELECT * FROM operators;
SELECT * FROM contacts;
SELECT * FROM assignment_groups;
SELECT * FROM assignment_groups_operators;
SELECT * FROM devices;
SELECT * FROM knowledges;
SELECT * FROM interactions;
SELECT * FROM incidents;
SELECT * FROM requests;
SELECT * FROM routineworks;
SELECT * FROM relations;

SELECT COUNT(*) FROM record_types;
SELECT COUNT(*) FROM statuses;
SELECT COUNT(*) FROM priorities;
SELECT COUNT(*) FROM closure_codes;
SELECT COUNT(*) FROM userroles;
SELECT COUNT(*) FROM positions;
SELECT COUNT(*) FROM depts;
SELECT COUNT(*) FROM operators;
SELECT COUNT(*) FROM contacts;
SELECT COUNT(*) FROM assignment_groups;
SELECT COUNT(*) FROM assignment_groups_operators;
SELECT COUNT(*) FROM devices;
SELECT COUNT(*) FROM knowledges;
SELECT COUNT(*) FROM interactions;
SELECT COUNT(*) FROM incidents;
SELECT COUNT(*) FROM requests;
SELECT COUNT(*) FROM routineworks;
SELECT COUNT(*) FROM relations;


-- ПРЕДСТАВЛЕНИЯ


/* Представление 1: Массовые инциденты
 * Инциденты, затронувшие сразу несколько пользователей
 * Для выборки смотрим в таблицу связей и выбираем инциденты, к которым прявязаны 
 * более одного обращения от пользователей
 */

CREATE OR REPLACE
VIEW mass_inc
AS SELECT 
	*
	FROM 
		(SELECT
			inc.id AS 'ID',
			COUNT(rel.record_1_id) AS 'Количество обращений',
			st.status AS 'Статус',
			inc.title AS 'Краткое описание'
		FROM relations AS rel 
		JOIN incidents AS inc 
		ON rel.record_2_id = inc.id
		JOIN statuses as st 
		ON inc.status = st.id
		WHERE rel.record_1_type = 1 AND rel.record_2_type = 2 
		GROUP BY rel.record_2_id) AS mass_inc
	WHERE `Количество обращений` > 1
	ORDER BY `Количество обращений` DESC, `ID`;

-- Проверяем представление
SELECT * FROM mass_inc;


/* Представление 2: Все новые записи
 * Обращения, Инциденты и Запросы на обслуживание со статусом 'open'
 * То есть записи, которые еще не взяли в работу
 */

CREATE OR REPLACE
VIEW open_records
AS SELECT 
	open_rec.`ID` AS 'ID',
	CONCAT(contacts.lastname, ' ', contacts.firstname) AS 'Контактное лицо',
	devices.name AS 'Затронутая КЕ',
	open_rec.`Краткое описание` AS 'Краткое описание'
	FROM 
		(SELECT  
			CONCAT('Обращение ', sd.id) AS 'ID',
			sd.contact_id AS 'Контактное лицо',
			sd.device_id AS 'Затронутая КЕ',
			sd.title AS 'Краткое описание'
		FROM interactions AS sd
		WHERE sd.status = 1
		UNION ALL
		SELECT
			CONCAT('Инцидент ', inc.id) AS 'ID',
			inc.contact_id AS 'Контактное лицо',
			inc.device_id AS 'Затронутая КЕ',
			inc.title AS 'Краткое описание'
		FROM incidents AS inc
		WHERE inc.status = 1
		UNION ALL
		SELECT 
			CONCAT('ЗНО ', req.id) AS 'ID',
			req.contact_id AS 'Контактное лицо',
			req.device_id AS 'Затронутая КЕ',
			req.title AS 'Краткое описание'
		FROM requests as req
		WHERE req.status = 1) AS open_rec
	JOIN contacts
	ON open_rec.`Контактное лицо` = contacts.operator_id
	JOIN devices
	ON open_rec.`Затронутая КЕ` = devices.id;

-- Проверяем представление
SELECT * FROM open_records;


/*
 * Представление 3: Количество инцидентов и ЗНО назначенных на операторов
 * Позволяет выявить ударников труда
 */

CREATE OR REPLACE
VIEW operators_occupation
AS 
SELECT
	records_count.assignee_id AS 'ID',
	operators.login AS 'Логин оператора',
	IFNULL(records_count.inc_count,0) + IFNULL(records_count.req_count,0) AS 'Общее количество записей',
	IFNULL(records_count.inc_count,0) AS 'Количество инцидентов',
	IFNULL(records_count.req_count,0) AS 'Количество ЗНО'
FROM
	(SELECT
		inc.assignee_id,
		inc.inc_count,
		req.req_count
	FROM 
		(SELECT 
			assignee_id,
			COUNT(*) AS inc_count
		FROM incidents
		GROUP BY assignee_id) AS inc
	LEFT JOIN
		(SELECT 
			assignee_id,
			COUNT(*) AS req_count
		FROM requests
		GROUP BY assignee_id) AS req
	ON inc.assignee_id = req.assignee_id
	UNION ALL
	SELECT
		req.assignee_id,
		inc.inc_count,
		req.req_count
	FROM 
		(SELECT 
			assignee_id,
			COUNT(*) AS inc_count
		FROM incidents
		GROUP BY assignee_id) AS inc
	RIGHT JOIN
		(SELECT 
			assignee_id,
			COUNT(*) AS req_count
		FROM requests
		GROUP BY assignee_id) AS req
	ON inc.assignee_id = req.assignee_id
	WHERE NOT EXISTS (SELECT 1 FROM incidents WHERE incidents.assignee_id = req.assignee_id)
	ORDER BY assignee_id) AS records_count
JOIN operators 
ON records_count.assignee_id = operators.id
ORDER BY 
	IFNULL(records_count.inc_count,0) + IFNULL(records_count.req_count,0) DESC,
	records_count.assignee_id;

-- Проверяем представление
SELECT * FROM operators_occupation;


-- ВЫБОРКИ


/*
 * Выборка 1: Все невыполненные и незакрытые Инциденты и ЗНО на текущего оператора.
 * На уровне приложения определяется ID оператора, под которым
 * пользователь зашел в систему
 * По этому ID делается выборка назначенных записей
 */

SET @user_id = 6; -- ID текущего пользователя

SELECT 
	CONCAT('Инцидент ', inc.id) AS 'ID',
	st.status AS 'Статус',
	pr.priority AS 'Приоритет',
	CONCAT(contacts.lastname, ' ', contacts.firstname) AS 'Контактное лицо',
	devices.name AS 'Затронутая КЕ',
	inc.title AS 'Краткое описание'
FROM incidents AS inc 
JOIN contacts
ON inc.contact_id = contacts.operator_id
JOIN devices
ON inc.device_id = devices.id
JOIN statuses AS st 
ON inc.status = st.id
JOIN priorities AS pr 
ON inc.priority = pr.id
WHERE inc.status NOT IN (4, 5) AND inc.assignee_id = @user_id

UNION

SELECT 
	CONCAT('ЗНО ', req.id) AS 'ID',
	st.status AS 'Статус',
	pr.priority AS 'Приоритет',
	CONCAT(contacts.lastname, ' ', contacts.firstname) AS 'Контактное лицо',
	devices.name AS 'Затронутая КЕ',
	req.title AS 'Краткое описание'
FROM requests AS req 
JOIN contacts
ON req.contact_id = contacts.operator_id
JOIN devices
ON req.device_id = devices.id
JOIN statuses AS st 
ON req.status = st.id
JOIN priorities AS pr 
ON req.priority = pr.id
WHERE req.status NOT IN (4, 5) AND req.assignee_id = @user_id;


/*
 * Выборка 2: Все обращения от VIP - пользователей
 */

SELECT 
	sd.id AS 'ID Обращения',	
	CONCAT(c.lastname, ' ', c.firstname) AS 'Имя пользователя',
	sd.title AS 'Краткое описание',
	st.status AS 'Статус'
FROM interactions AS sd
JOIN contacts AS c 
ON sd.contact_id = c.operator_id
JOIN statuses AS st 
ON sd.status = st.id
WHERE c.vip IS TRUE
ORDER BY FIELD (st.status, 'open', 'work in progress', 'suspended', 'resolved', 'closed'), sd.contact_id;


/*
 * Выборка 3: Инциденты, вызванные Регламентными работами
 */ 

SELECT 
	rel.record_1_id AS 'ID Регламентной работы',
	rr.name AS 'Наименование Регламентной работы',
	rel.record_2_id AS 'ID Инцидента',
	st.status AS 'Статус Инцидента',
	inc.title AS 'Описание Инцидента',
	IF( mass_inc.ID IS NOT NULL, 'Да', 'Нет' ) AS 'Массовый Инцидент'
FROM relations AS rel
JOIN routineworks AS rr 
ON rel.record_1_id = rr.id 
JOIN incidents AS inc 
ON rel.record_2_id = inc.id 
LEFT JOIN mass_inc
ON inc.id = mass_inc.ID
JOIN statuses AS st 
ON inc.status = st.id
WHERE record_1_type = 4 AND record_2_type = 2;


/*
 * Выборка 4: Количество операторов в рабочих группах
 */

SELECT
	ag.id AS 'ID',
	ag.name AS 'Наименование',
	CONCAT(c.lastname, ' ',c.firstname) AS 'Руководитель',
	COUNT(ago.operator_id) AS 'Количество операторов'
FROM assignment_groups AS ag 
JOIN assignment_groups_operators AS ago 
ON ag.id = ago.group_id
JOIN contacts AS c 
ON ag.head_id = c.operator_id
GROUP BY ag.id;


-- ТРИГГЕРЫ

/*
 * Триггер 1: На закрытие обращения без указания решения и кода закрытия
 */

DROP TRIGGER IF EXISTS interactions_b_u_closure;
DELIMITER //
CREATE TRIGGER interactions_b_u_closure BEFORE UPDATE ON interactions
FOR EACH ROW
BEGIN
	IF((NEW.resolution IS NULL OR NEW.resolution = '' OR NEW.closure_code IS NULL OR NEW.closure_code = '') AND NEW.status = 5) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Атрибуты [Решение] и [Код закрытия] являются обязательными при закрытии Обращения. Обновление отменено.';
	END IF;
END//
DELIMITER ;

-- Проверяем триггер
SELECT 
	id,
	status,
	closure_code,
	resolution
FROM interactions WHERE id = 1;

UPDATE interactions
SET 
	status = 2,
	closure_code = NULL,
	resolution = NULL
WHERE id = 1;

UPDATE interactions
SET status = 5
WHERE id = 1;


/*
 * Триггер 2: На добавление документа базы знаний без краткого или полного описания
 * Хотя бы один из этих двух атрибутов должен быть указан
 */

DROP TRIGGER IF EXISTS knowledges_b_a_description;
DELIMITER //
CREATE TRIGGER knowledges_b_a_description BEFORE INSERT ON knowledges
FOR EACH ROW
BEGIN
	IF((NEW.title IS NULL OR NEW.title = '') AND (NEW.description IS NULL OR NEW.description = '')) THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'При создании документа базы знаний необходимо указать [Наименование] и [Подробное описание]. Добавление отменено.';
	END IF;
END//
DELIMITER ;

-- Проверяем триггер
SELECT * FROM knowledges WHERE id = 21;

DELETE FROM knowledges WHERE id = 21;

INSERT INTO knowledges (id, title, description, author_id, `type`) 
VALUES (21, '', NULL, 1, 5);


-- ПРОЦЕДУРЫ И ФУНКЦИИ

/*
 * Процедура: Возвращает в работу все ЗНО, приостановленные более недели назад
 */

DELIMITER //
DROP PROCEDURE IF EXISTS return_req_to_work//
CREATE PROCEDURE return_req_to_work()
BEGIN
	UPDATE requests
	SET status = 2
	WHERE status = 3 AND updated_at < (NOW() - INTERVAL 7 DAY);
END//
DELIMITER ;

-- Проверяем процедуру
-- Смотрим наличие приостановленных ЗНО
SELECT 
	req.id,
	req.updated_at
FROM requests AS req 
WHERE req.status = 3
ORDER BY req.updated_at;

-- Запускаем процедуру
CALL return_req_to_work;

-- Снова смотрим наличие ЗНО
SELECT 
	req.id,
	req.updated_at
FROM requests AS req 
WHERE req.status = 3
ORDER BY req.updated_at;


/*
 * Функция: возвращает id Обращения, которое нужно взять в обработку в первую очередь
 * Выбирать будем по следующим параметрам:
 * 1. От VIP-пользователя
 * 2. Самое раннее по дате создания
 * 3. Самое ранее по номеру id
 * Статус рассматриваем 'open', т.к. остальные статусы значат, что уже в обработке
 */

DELIMITER //
DROP FUNCTION IF EXISTS next_interaction//
CREATE FUNCTION next_interaction()
RETURNS INT READS SQL DATA
BEGIN
	DECLARE sd_id INT;
	SET sd_id = (
		SELECT 
			sd.id
		FROM interactions AS sd 
		JOIN contacts AS c 
		ON sd.contact_id = c.operator_id
		WHERE sd.status = 1
		ORDER BY c.vip DESC, sd.created_at, sd.id
		LIMIT 1
	);
	RETURN sd_id;
END//
DELIMITER ;

-- Проверяем функцию

-- Делаем выборку
SELECT 
	sd.id AS 'ID',
	CONCAT(c.lastname,' ', c.firstname) AS 'Пользователь',
	c.vip AS 'VIP',
	st.status AS 'Статус',
	sd.created_at AS 'Дата создания'
FROM interactions AS sd 
JOIN contacts AS c 
ON sd.contact_id = c.operator_id
JOIN statuses AS st 
ON sd.status = st.id
WHERE sd.status = 1
ORDER BY c.vip DESC, sd.created_at, sd.id;

-- Запускаем функцию
SELECT next_interaction();

-- Возьмем Обращение в работу
UPDATE interactions
SET status = 2
WHERE id = next_interaction();

-- Снова запускаем функцию
SELECT next_interaction();













