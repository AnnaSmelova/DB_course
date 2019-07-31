DROP DATABASE IF EXISTS sm;
CREATE DATABASE sm;

USE sm;

-- 1. Операторы (operators)
DROP TABLE IF EXISTS operators;
CREATE TABLE operators (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  login VARCHAR(100) NOT NULL UNIQUE COMMENT 'логин для входа в систему',
  `password` VARCHAR(255) COMMENT 'пароль для входа в систему',
  userrole VARCHAR(50) COMMENT 'тип учетной записи',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  INDEX operators_login_idx (login)
) COMMENT = 'Таблица операторов';

-- 2. Контакты (contacts)
DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(50) NOT NULL COMMENT 'имя пользователя',
  lastname VARCHAR(255) NOT NULL COMMENT 'фамилия пользователя',
  fullname VARCHAR(255) NOT NULL COMMENT 'полное имя пользователя',
  email VARCHAR(120) NOT NULL UNIQUE COMMENT 'электронный адрес',
  `position` VARCHAR(50) COMMENT 'должность',
  department VARCHAR(50) COMMENT 'подразделение',
  vip BOOLEAN COMMENT 'приоритетный пользователь',
  operator_id INT UNSIGNED NOT NULL UNIQUE COMMENT 'логин для входа в систему', -- id operators
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  INDEX contacts_fullname_idx (fullname),
  INDEX contacts_email_idx (email),
  UNIQUE unique_fullname(fullname),
  CONSTRAINT contacts_operator_id_fk FOREIGN KEY (operator_id) REFERENCES operators(id) 
) COMMENT = 'Таблица контактов';

-- 3. Рабочие группы (assignment_groups)
DROP TABLE IF EXISTS assignment_groups;
CREATE TABLE assignment_groups (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE COMMENT 'наименование группы',
  head_id INT UNSIGNED COMMENT 'руководитель группы', -- id operators
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  INDEX assignment_groups_name_idx (name),
  CONSTRAINT assignment_groups_head_id_fk FOREIGN KEY (head_id) REFERENCES operators(id) 
) COMMENT = 'Таблица рабочих групп';

-- 4. КЕ (devices)
DROP TABLE IF EXISTS devices;
CREATE TABLE devices (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'наименование КЕ',
  operator_id INT UNSIGNED COMMENT 'владелец КЕ', -- id operators 
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT devices_operator_id_fk FOREIGN KEY (operator_id) REFERENCES operators(id)
) COMMENT = 'Таблица конфигурационных единиц';

-- 5. Типы записей (record_types)
DROP TABLE IF EXISTS record_types;
CREATE TABLE record_types (
  name VARCHAR(50) NOT NULL PRIMARY KEY,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT = 'Таблица типов записей';

-- 6. База знаний (knowledges)
DROP TABLE IF EXISTS knowledges;
CREATE TABLE knowledges (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) COMMENT 'наименование документа',
  description TEXT COMMENT 'подробное описание',
  author_id INT UNSIGNED COMMENT 'автор документа', -- id operators
  `type` VARCHAR(50) COMMENT 'тип записи',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT knowledges_author_id_fk FOREIGN KEY (author_id) REFERENCES operators(id),
  CONSTRAINT knowledges_type_fk FOREIGN KEY (`type`) REFERENCES record_types(name)
) COMMENT = 'Таблица базы знаний';

-- 7. Обращения (interactions)
DROP TABLE IF EXISTS interactions;
CREATE TABLE interactions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  contact_id INT UNSIGNED NOT NULL COMMENT 'инициатор обращения', -- id operators
  title VARCHAR(255) NOT NULL COMMENT 'краткое описание',
  description TEXT COMMENT 'подробное описание',
  resolution TEXT COMMENT 'решение',
  closure_code VARCHAR(50) COMMENT 'код закрытия',
  device_id INT UNSIGNED COMMENT 'затронутая конфигурационная единица',  -- id devices
  int_type VARCHAR(50) COMMENT 'тип обращения', -- ЗНО или Инцидент
  priority VARCHAR(50) NOT NULL COMMENT 'приоритет обращения',
  status VARCHAR(50) NOT NULL COMMENT 'статус обращения',
  `type` VARCHAR(50) COMMENT 'тип записи',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT interactions_contact_id_fk FOREIGN KEY (contact_id) REFERENCES operators(id),
  CONSTRAINT interactions_device_id_fk FOREIGN KEY (device_id) REFERENCES devices(id),
  CONSTRAINT interactions_type_fk FOREIGN KEY (`type`) REFERENCES record_types(name)
) COMMENT = 'Таблица обращений';

-- 8. Инциденты (incidents)
DROP TABLE IF EXISTS incidents;
CREATE TABLE incidents (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  contact_id INT UNSIGNED COMMENT 'инициатор', -- id operators
  title VARCHAR(255) NOT NULL COMMENT 'краткое описание',
  description TEXT COMMENT 'подробное описание',
  resolution TEXT COMMENT 'решение',
  closure_code VARCHAR(50) COMMENT 'код закрытия',
  priority VARCHAR(50) NOT NULL COMMENT 'приоритет',
  status VARCHAR(50) NOT NULL COMMENT 'статус инцидента',
  group_id INT UNSIGNED COMMENT 'ответственная группа', -- id assignment_groups
  assignee_id INT UNSIGNED COMMENT 'ответственный исполнитель', -- id operators
  device_id INT UNSIGNED COMMENT 'затронутая конфигурационная единица',  -- id devices
  `type` VARCHAR(50) COMMENT 'тип записи',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT incidents_contact_id_fk FOREIGN KEY (contact_id) REFERENCES operators(id),
  CONSTRAINT incidents_device_id_fk FOREIGN KEY (device_id) REFERENCES devices(id),
  CONSTRAINT incidents_assignee_id_fk FOREIGN KEY (assignee_id) REFERENCES operators(id),
  CONSTRAINT incidents_group_id_fk FOREIGN KEY (group_id) REFERENCES assignment_groups(id),
  CONSTRAINT incidents_type_fk FOREIGN KEY (`type`) REFERENCES record_types(name)
) COMMENT = 'Таблица инцидентов';

-- 9. Запросы на обслуживание (requests)
DROP TABLE IF EXISTS requests;
CREATE TABLE requests (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  contact_id INT UNSIGNED COMMENT 'инициатор', -- id operators
  title VARCHAR(255) NOT NULL COMMENT 'краткое описание',
  description TEXT COMMENT 'подробное описание',
  resolution TEXT COMMENT 'решение',
  closure_code VARCHAR(50) COMMENT 'код закрытия',
  priority VARCHAR(50) NOT NULL COMMENT 'приоритет',
  status VARCHAR(50) NOT NULL COMMENT 'статус ЗНО',
  group_id INT UNSIGNED COMMENT 'ответственная группа',  -- id assignment_groups
  assignee_id INT UNSIGNED COMMENT 'ответственный исполнитель', -- id operators
  device_id INT UNSIGNED COMMENT 'затронутая конфигурационная единица', -- id devices 
  `type` VARCHAR(50) COMMENT 'тип записи',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT requests_contact_id_fk FOREIGN KEY (contact_id) REFERENCES operators(id),
  CONSTRAINT requests_device_id_fk FOREIGN KEY (device_id) REFERENCES devices(id),
  CONSTRAINT requests_assignee_id_fk FOREIGN KEY (assignee_id) REFERENCES operators(id),
  CONSTRAINT requests_group_id_fk FOREIGN KEY (group_id) REFERENCES assignment_groups(id),
  CONSTRAINT requests_type_fk FOREIGN KEY (`type`) REFERENCES record_types(name)
) COMMENT = 'Таблица запросов на обслуживание';

-- 10. Регламентные работы (routineworks)
DROP TABLE IF EXISTS routineworks;
CREATE TABLE routineworks (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'наименование работы',
  status VARCHAR(50) NOT NULL COMMENT 'статус регламентной работы',
  group_id INT UNSIGNED COMMENT 'ответственная группа', -- id assignment_groups
  assignee_id INT UNSIGNED COMMENT 'ответственный исполнитель', -- id operators
  description TEXT COMMENT 'подробное описание',
  next_date DATE COMMENT 'дата следующего запуска',
  device_id INT UNSIGNED COMMENT 'затронутая конфигурационная единица', -- id devices
  `type` VARCHAR(50) COMMENT 'тип записи',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  UNIQUE unique_name(name(10)),
  CONSTRAINT routineworks_device_id_fk FOREIGN KEY (device_id) REFERENCES devices(id),
  CONSTRAINT routineworks_assignee_id_fk FOREIGN KEY (assignee_id) REFERENCES operators(id),
  CONSTRAINT routineworks_group_id_fk FOREIGN KEY (group_id) REFERENCES assignment_groups(id),
  CONSTRAINT routineworks_type_fk FOREIGN KEY (`type`) REFERENCES record_types(name)
) COMMENT = 'Таблица регламентных работ';


-- 11. Связи (relations)
DROP TABLE IF EXISTS relations;
CREATE TABLE relations (
  record_1_id INT UNSIGNED NOT NULL COMMENT 'запись, вызвавшая связь', -- id 
  record_1_type VARCHAR(50) NOT NULL,
  record_2_id INT UNSIGNED NOT NULL COMMENT 'вызванная запись', -- id
  record_2_type VARCHAR(50) NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (record_1_id, record_1_type, record_2_id, record_2_type),
  CONSTRAINT relations_record_1_type_fk FOREIGN KEY (record_1_type) REFERENCES record_types(name),
  CONSTRAINT relations_record_2_type_fk FOREIGN KEY (record_2_type) REFERENCES record_types(name)
) COMMENT = 'Таблица связей';

-- 12. Состав групп (assignment_groups_operators)
DROP TABLE IF EXISTS assignment_groups_operators;
CREATE TABLE assignment_groups_operators (
  group_id INT UNSIGNED NOT NULL COMMENT 'Группа', -- id assignment_groups 
  operator_id INT UNSIGNED NOT NULL COMMENT 'логин оператора', -- id operators
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (group_id, operator_id),
  CONSTRAINT assignment_groups_operators_group_id_fk FOREIGN KEY (group_id) REFERENCES assignment_groups(id),
  CONSTRAINT assignment_groups_operators_operator_id_fk FOREIGN KEY (operator_id) REFERENCES operators(id)
) COMMENT = 'Таблица связей';



