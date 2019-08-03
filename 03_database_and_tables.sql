DROP DATABASE IF EXISTS sm;
CREATE DATABASE sm;

USE sm;

-- 1. Типы записей (record_types)
DROP TABLE IF EXISTS record_types;
CREATE TABLE record_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT = 'Таблица типов записей';

-- 2. Статусы записей (statuses)
DROP TABLE IF EXISTS statuses;
CREATE TABLE statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  status VARCHAR(50) NOT NULL COMMENT 'статус',
  record_type_id INT UNSIGNED COMMENT 'Тип записи', -- id record_types
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  INDEX statuses_status_record_type_id_lastname_idx (status, record_type_id),
  CONSTRAINT statuses_record_type_id_fk FOREIGN KEY (record_type_id) REFERENCES record_types(id)
) COMMENT = 'Таблица статусов';

-- 3. Приоритеты записей (priorities)
DROP TABLE IF EXISTS priorities;
CREATE TABLE priorities (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  priority VARCHAR(50) NOT NULL UNIQUE COMMENT 'приоритет',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT = 'Таблица приоритетов';

-- 4. Коды закрытия (closure_codes)
DROP TABLE IF EXISTS closure_codes;
CREATE TABLE closure_codes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE COMMENT 'код закрытия',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT = 'Таблица кодов закрытия';

-- 5. Типы учетных записей (userroles)
DROP TABLE IF EXISTS userroles;
CREATE TABLE userroles (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE COMMENT 'наименование учетной записи',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT = 'Таблица типов учетных записей';

-- 6. Должности (positions)
DROP TABLE IF EXISTS positions;
CREATE TABLE positions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE COMMENT 'должность',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT = 'Таблица должностей';

-- 7. Подразделения (depts)
DROP TABLE IF EXISTS depts;
CREATE TABLE depts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  dept VARCHAR(50) NOT NULL UNIQUE COMMENT 'подразделение',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT = 'Таблица подразделений';

-- 8. Операторы (operators)
DROP TABLE IF EXISTS operators;
CREATE TABLE operators (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  login VARCHAR(100) NOT NULL UNIQUE COMMENT 'логин для входа в систему',
  `password` VARCHAR(255) COMMENT 'пароль для входа в систему',
  userrole_id INT UNSIGNED COMMENT 'тип учетной записи', -- id userroles
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  INDEX operators_login_idx (login),
  CONSTRAINT operators_userrole_id_fk FOREIGN KEY (userrole_id) REFERENCES userroles(id) 
) COMMENT = 'Таблица операторов';

-- 9. Контакты (contacts)
DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(50) NOT NULL COMMENT 'имя пользователя',
  lastname VARCHAR(255) NOT NULL COMMENT 'фамилия пользователя',
  email VARCHAR(120) NOT NULL UNIQUE COMMENT 'электронный адрес',
  position_id INT UNSIGNED COMMENT 'должность', -- id positions
  department_id INT UNSIGNED COMMENT 'подразделение', -- id depts
  vip BOOLEAN COMMENT 'приоритетный пользователь',
  operator_id INT UNSIGNED NOT NULL UNIQUE COMMENT 'логин для входа в систему', -- id operators
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  INDEX contacts_firstname_lastname_idx (firstname, lastname),
  INDEX contacts_email_idx (email),
  CONSTRAINT contacts_operator_id_fk FOREIGN KEY (operator_id) REFERENCES operators(id),
  CONSTRAINT contacts_position_id_fk FOREIGN KEY (position_id) REFERENCES positions(id),
  CONSTRAINT contacts_department_id_fk FOREIGN KEY (department_id) REFERENCES depts(id) 
) COMMENT = 'Таблица контактов';

-- 10. Рабочие группы (assignment_groups)
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

-- 11. Состав групп (assignment_groups_operators)
DROP TABLE IF EXISTS assignment_groups_operators;
CREATE TABLE assignment_groups_operators (
  group_id INT UNSIGNED NOT NULL COMMENT 'Группа', -- id assignment_groups 
  operator_id INT UNSIGNED NOT NULL COMMENT 'логин оператора', -- id operators
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (group_id, operator_id),
  CONSTRAINT assignment_groups_operators_group_id_fk FOREIGN KEY (group_id) REFERENCES assignment_groups(id),
  CONSTRAINT assignment_groups_operators_operator_id_fk FOREIGN KEY (operator_id) REFERENCES operators(id)
) COMMENT = 'Таблица состава рабочих групп';

-- 12. КЕ (devices)
DROP TABLE IF EXISTS devices;
CREATE TABLE devices (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'наименование КЕ',
  operator_id INT UNSIGNED COMMENT 'владелец КЕ', -- id operators 
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT devices_operator_id_fk FOREIGN KEY (operator_id) REFERENCES operators(id)
) COMMENT = 'Таблица конфигурационных единиц';

-- 13. База знаний (knowledges)
DROP TABLE IF EXISTS knowledges;
CREATE TABLE knowledges (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) COMMENT 'наименование документа',
  description TEXT COMMENT 'подробное описание',
  author_id INT UNSIGNED COMMENT 'автор документа', -- id operators
  type_id INT UNSIGNED COMMENT 'тип записи', -- id record_types
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT knowledges_author_id_fk FOREIGN KEY (author_id) REFERENCES operators(id),
  CONSTRAINT knowledges_type_id_fk FOREIGN KEY (type_id) REFERENCES record_types(id)
) COMMENT = 'Таблица базы знаний';

-- 14. Обращения (interactions)
DROP TABLE IF EXISTS interactions;
CREATE TABLE interactions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  contact_id INT UNSIGNED NOT NULL COMMENT 'инициатор обращения', -- id operators
  title VARCHAR(255) NOT NULL COMMENT 'краткое описание',
  description TEXT COMMENT 'подробное описание',
  resolution TEXT COMMENT 'решение',
  closure_code_id INT UNSIGNED COMMENT 'код закрытия', -- id closure_codes
  device_id INT UNSIGNED COMMENT 'затронутая конфигурационная единица',  -- id devices
  int_type_id INT UNSIGNED COMMENT 'тип обращения', -- ЗНО или Инцидент -- id record_types
  priority_id INT UNSIGNED NOT NULL COMMENT 'приоритет обращения', -- id priorities
  status_id INT UNSIGNED NOT NULL COMMENT 'статус обращения', -- id statuses
  type_id INT UNSIGNED COMMENT 'тип записи', -- id record_types
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT interactions_contact_id_fk FOREIGN KEY (contact_id) REFERENCES operators(id),
  CONSTRAINT interactions_closure_code_id_fk FOREIGN KEY (closure_code_id) REFERENCES closure_codes(id),
  CONSTRAINT interactions_device_id_fk FOREIGN KEY (device_id) REFERENCES devices(id),
  CONSTRAINT interactions_int_type_id_fk FOREIGN KEY (int_type_id) REFERENCES record_types(id),
  CONSTRAINT interactions_priority_id_fk FOREIGN KEY (priority_id) REFERENCES priorities(id),
  CONSTRAINT interactions_status_id_fk FOREIGN KEY (status_id) REFERENCES statuses(id),
  CONSTRAINT interactions_type_id_fk FOREIGN KEY (type_id) REFERENCES record_types(id)
) COMMENT = 'Таблица обращений';

-- 15. Инциденты (incidents)
DROP TABLE IF EXISTS incidents;
CREATE TABLE incidents (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  contact_id INT UNSIGNED COMMENT 'инициатор', -- id operators
  title VARCHAR(255) NOT NULL COMMENT 'краткое описание',
  description TEXT COMMENT 'подробное описание',
  resolution TEXT COMMENT 'решение',
  closure_code_id INT UNSIGNED COMMENT 'код закрытия', -- id closure_codes
  priority_id INT UNSIGNED NOT NULL COMMENT 'приоритет', -- id priorities
  status_id INT UNSIGNED NOT NULL COMMENT 'статус инцидента', -- id statuses
  group_id INT UNSIGNED COMMENT 'ответственная группа', -- id assignment_groups
  assignee_id INT UNSIGNED COMMENT 'ответственный исполнитель', -- id operators
  device_id INT UNSIGNED COMMENT 'затронутая конфигурационная единица',  -- id devices
  type_id INT UNSIGNED COMMENT 'тип записи', -- id record_types
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT incidents_contact_id_fk FOREIGN KEY (contact_id) REFERENCES operators(id),
  CONSTRAINT incidents_closure_code_id_fk FOREIGN KEY (closure_code_id) REFERENCES closure_codes(id),
  CONSTRAINT incidents_priority_id_fk FOREIGN KEY (priority_id) REFERENCES priorities(id),
  CONSTRAINT incidents_status_id_fk FOREIGN KEY (status_id) REFERENCES statuses(id),
  CONSTRAINT incidents_group_id_fk FOREIGN KEY (group_id) REFERENCES assignment_groups(id),
  CONSTRAINT incidents_assignee_id_fk FOREIGN KEY (assignee_id) REFERENCES operators(id),
  CONSTRAINT incidents_device_id_fk FOREIGN KEY (device_id) REFERENCES devices(id),
  CONSTRAINT incidents_type_id_fk FOREIGN KEY (type_id) REFERENCES record_types(id)
) COMMENT = 'Таблица инцидентов';

-- 16. Запросы на обслуживание (requests)
DROP TABLE IF EXISTS requests;
CREATE TABLE requests (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  contact_id INT UNSIGNED COMMENT 'инициатор', -- id operators
  title VARCHAR(255) NOT NULL COMMENT 'краткое описание',
  description TEXT COMMENT 'подробное описание',
  resolution TEXT COMMENT 'решение',
  closure_code_id INT UNSIGNED COMMENT 'код закрытия', -- id closure_codes
  priority_id INT UNSIGNED NOT NULL COMMENT 'приоритет', -- id priorities
  status_id INT UNSIGNED NOT NULL COMMENT 'статус ЗНО', -- id statuses
  group_id INT UNSIGNED COMMENT 'ответственная группа',  -- id assignment_groups
  assignee_id INT UNSIGNED COMMENT 'ответственный исполнитель', -- id operators
  device_id INT UNSIGNED COMMENT 'затронутая конфигурационная единица', -- id devices 
  type_id INT UNSIGNED COMMENT 'тип записи', -- id record_types
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT requests_contact_id_fk FOREIGN KEY (contact_id) REFERENCES operators(id),
  CONSTRAINT requests_closure_code_id_fk FOREIGN KEY (closure_code_id) REFERENCES closure_codes(id),
  CONSTRAINT requests_priority_id_fk FOREIGN KEY (priority_id) REFERENCES priorities(id),
  CONSTRAINT requests_status_id_fk FOREIGN KEY (status_id) REFERENCES statuses(id),
  CONSTRAINT requests_group_id_fk FOREIGN KEY (group_id) REFERENCES assignment_groups(id),
  CONSTRAINT requests_assignee_id_fk FOREIGN KEY (assignee_id) REFERENCES operators(id),
  CONSTRAINT requests_device_id_fk FOREIGN KEY (device_id) REFERENCES devices(id),
  CONSTRAINT requests_type_id_fk FOREIGN KEY (type_id) REFERENCES record_types(id)
) COMMENT = 'Таблица запросов на обслуживание';

-- 17. Регламентные работы (routineworks)
DROP TABLE IF EXISTS routineworks;
CREATE TABLE routineworks (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'наименование работы',
  status_id INT UNSIGNED NOT NULL COMMENT 'статус регламентной работы', -- id statuses
  group_id INT UNSIGNED COMMENT 'ответственная группа', -- id assignment_groups
  assignee_id INT UNSIGNED COMMENT 'ответственный исполнитель', -- id operators
  description TEXT COMMENT 'подробное описание',
  next_date DATE COMMENT 'дата следующего запуска',
  device_id INT UNSIGNED COMMENT 'затронутая конфигурационная единица', -- id devices
  type_id INT UNSIGNED COMMENT 'тип записи', -- id record_types
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  UNIQUE unique_name(name(10)),
  CONSTRAINT routineworks_status_id_fk FOREIGN KEY (status_id) REFERENCES statuses(id),
  CONSTRAINT routineworks_group_id_fk FOREIGN KEY (group_id) REFERENCES assignment_groups(id),
  CONSTRAINT routineworks_assignee_id_fk FOREIGN KEY (assignee_id) REFERENCES operators(id),
  CONSTRAINT routineworks_device_id_fk FOREIGN KEY (device_id) REFERENCES devices(id),
  CONSTRAINT routineworks_type_id_fk FOREIGN KEY (type_id) REFERENCES record_types(id)
) COMMENT = 'Таблица регламентных работ';


-- 18. Связи (relations)
DROP TABLE IF EXISTS relations;
CREATE TABLE relations (
  record_1_id INT UNSIGNED NOT NULL COMMENT 'запись, вызвавшая связь', -- id 
  record_1_type_id INT UNSIGNED NOT NULL, -- id record_types
  record_2_id INT UNSIGNED NOT NULL COMMENT 'вызванная запись', -- id
  record_2_type_id INT UNSIGNED NOT NULL, -- id record_types
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (record_1_id, record_1_type_id, record_2_id, record_2_type_id),
  CONSTRAINT relations_record_1_type_id_fk FOREIGN KEY (record_1_type_id) REFERENCES record_types(id),
  CONSTRAINT relations_record_2_type_id_fk FOREIGN KEY (record_2_type_id) REFERENCES record_types(id)
) COMMENT = 'Таблица связей';





