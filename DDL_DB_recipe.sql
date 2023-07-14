/* База данных продуктов, блюд, меню в организациях общественного питания.  
 На основе данной базы данных возможно рассчитать энергетическую и пищевую ценность рационов питания, стоимость блюд меню. */
DROP DATABASE IF EXISTS recipe;
CREATE DATABASE recipe CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE recipe;

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL COMMENT 'Название продукта',
  k1 FLOAT NOT NULL DEFAULT 1 COMMENT 'Сезонный коэффициент на зиму',  
  k2 FLOAT NOT NULL DEFAULT 1 COMMENT 'Сезонный коэффициент на весну', 
  k3 FLOAT NOT NULL DEFAULT 1 COMMENT 'Сезонный коэффициент на лето', 
  k4 FLOAT NOT NULL DEFAULT 1 COMMENT 'Сезонный коэффициент на осень', 
  prot FLOAT COMMENT 'Кол-во белков на 100 гр. продукта', 
  fat FLOAT COMMENT 'Кол-во жиров на 100 гр. продукта', 
  carb FLOAT COMMENT 'Кол-во углеводов на 100 гр. продукта', 
  measure VARCHAR(5) NOT NULL COMMENT 'Единица измерения продукта: кг, л, шт.', 
  INDEX (name) COMMENT  'Индекс по названию продукта'
) COMMENT = 'Продукты';

INSERT INTO products (name, k1, k2, k3, k4, prot, fat, carb, measure) 
VALUES 	('Свекла', 1, 1, 1.064, 1.064, 1.5, 0.1, 8.8, 'кг'),
		('Капуста', 1, 1, 1, 1, 1.8, 0.74, 4.7, 'кг'),
		('Картофель', 1, 1.075, 1.157, 1.255, 2, 0.4, 16.3, 'кг'),
		('Морковь', 1, 1, 1.064, 1.064, 1.3, 0.1, 6.9, 'кг'),
		('Лук репчатый', 1, 1, 1, 1, 1.3, 0.1, 6.9, 'кг'),
		('Томатная паста', 1, 1, 1, 1, 4.8, 0, 20, 'кг'),
		('Масло растительное', 1, 1, 1, 1, 0, 99.9, 0, 'кг'),
		('Сахар', 1, 1, 1, 1, 0, 0, 99.9, 'кг'),
		('Свинина', 1, 1, 1, 1, 14.3, 33.3, NULL, 'кг'),
		('Кислота лимонная', 1, 1, 1, 1, NULL, NULL, NULL, 'кг'),
		('Лавровый лист', 1, 1, 1, 1, NULL, NULL, NULL, 'кг'),
		('Соль', 1, 1, 1, 1, NULL, NULL, NULL, 'кг'),
		('Вода', 1, 1, 1, 1, NULL, NULL, NULL, 'кг');
		
DROP TABLE IF EXISTS sources;
CREATE TABLE sources (
	id SERIAL PRIMARY KEY,
	name varchar(100) NOT NULL COMMENT 'Название сборника рецептур', 
	INDEX (name) COMMENT 'Индекс по названию сборника')  
	COMMENT = 'Сборник справочников блюд';

INSERT INTO sources 
VALUES 	(DEFAULT, 'Сборник рецептур и кулинарных изделий'),
		(DEFAULT, 'Сборник рецептур и кулинарных изделий национальных кухонь'),
		(DEFAULT, 'Диетический сборник'),
		(DEFAULT, 'Сборник мучных, кондитерских, булочных изделий'),
		(DEFAULT, 'Сборник рецептур и кулинарных изделий национальных кухонь'),
		(DEFAULT, 'Сборник технологических нормативов, рецептур блюд и кулинарных изделий');
		
		
DROP TABLE IF EXISTS ds;
CREATE TABLE ds (
	id SERIAL PRIMARY KEY,
	id_sources BIGINT UNSIGNED NOT NULL COMMENT 'ИД сборника блюд', 
	page_number_source INT UNSIGNED COMMENT 'Номер страницы в сборнике', 
	name varchar(100) NOT NULL COMMENT 'Название блюда', 
	quantity FLOAT NOT NULL COMMENT 'Вес блюда по сборнику в гр.', 
	INDEX (name),
	CONSTRAINT fk_ds_id_sources FOREIGN KEY (id_sources) REFERENCES sources(id))  
COMMENT = 'Блюда';
	
INSERT INTO ds(id_sources, page_number_source, name, quantity) 
VALUES 	(1, 21, 'Борщ', 20000),
		(2, 31, 'Щи', 25000),
		(6, 41, 'Тущенная свинина', 22500);
	
DROP TABLE IF EXISTS zakladki;
CREATE TABLE zakladki (
	id_ds BIGINT UNSIGNED NOT NULL,
	id_product BIGINT UNSIGNED NOT NULL,
	brutto FLOAT NOT NULL COMMENT 'Вес брутто продукта в блюде', 
	netto FLOAT NOT NULL COMMENT 'Вес нетто продукта в блюде',  
	INDEX zakladki_id_ds_idx (id_ds) COMMENT 'Индекс по блюду',
	INDEX zakladki_id_product_idx (id_product) COMMENT 'Индекс по продукту',
	CONSTRAINT fk_zakladki_id_ds FOREIGN KEY (id_ds) REFERENCES ds(id),
	CONSTRAINT fk_zakladki_id_product FOREIGN KEY (id_product) REFERENCES products(id)
	)	COMMENT = 'Состав блюда';

INSERT INTO zakladki 
VALUES 	(1, 1, 4, 3.2),
		(1, 2, 2, 1.6),
		(1, 3, 2.14, 1.6),
		(1, 4, 1, 0.8),
		(1, 5, 0.96, 0.8),
		(1, 6, 0.24, 0.24),
		(1, 7, 0.33, 0.33),
		(1, 8, 0.2, 0.2),
		(1, 8, 2, 2),
		(1, 10, 0.0096, 0.0096),
		(1, 11, 0.0008, 0.0008),
		(1, 12, 0.12, 0.12),
		(1, 13, 16, 16),
		(2, 2, 10.01, 7),
		(2, 3, 4.662, 3.5),
		(2, 4, 1.75, 1.4),
		(2, 5, 1.68, 1.4),
		(2, 6, 0.14, 0.14),
		(2, 7, 0.7, 0.7),
		(2, 11, 0.0014, 0.0014),
		(2, 12, 0.21, 0.21),
		(2, 13, 28, 28),
		(3, 9, 6.96, 5.92),
		(3, 7, 0.45, 0.45),
		(3, 12, 0.135, 0.135),
		(3, 2, 25.7958, 20.628),
		(3, 4, 0.45, 0.36),
		(3, 5, 0.864, 0.72),
		(3, 6, 0.4275, 0.4275),
		(3, 10, 0.0162, 0.0162),
		(3, 8, 0.54, 0.54),
		(3, 11, 0.018, 0.018);
		
	
DROP TABLE IF EXISTS list_prices;
CREATE TABLE list_prices (
	id SERIAL PRIMARY KEY,
	name varchar(100) NOT NULL COMMENT 'Название прайса на продукты', 
	INDEX (name)) COMMENT 'Индекс по названию прайса' 
COMMENT = 'Реестр прайсов';

INSERT INTO list_prices 
VALUES 	(DEFAULT, 'Реестр цен школы'),
		(DEFAULT, 'Реестр цен детского сада'),
		(DEFAULT, 'Реестр цен столовой'),
		(DEFAULT, 'Реестр цен ресторана'),
		(DEFAULT, 'Реестр цен кафе');

DROP TABLE IF EXISTS prices;
CREATE TABLE prices (
	id_list_prices BIGINT UNSIGNED NOT NULL,
	id_product BIGINT UNSIGNED NOT NULL,
	product_price FLOAT NOT NULL COMMENT 'Цена продукта за 1 кг/шт/л', 
	coeff_price FLOAT NOT NULL DEFAULT 1 COMMENT 'Коэффициент прибавки/скидки цены',  
	INDEX prices_id_lp_idx (id_list_prices) COMMENT 'Индекс по прайсам',
	INDEX prices_id_product_idx (id_product) COMMENT 'Индекс по продуктам',
	CONSTRAINT fk_prices_id_lp FOREIGN KEY (id_list_prices) REFERENCES list_prices(id),
	CONSTRAINT fk_prices_id_product FOREIGN KEY (id_product) REFERENCES products(id)
	)	COMMENT = 'Прайс на продукты';

INSERT INTO prices 
VALUES 	(1, 1, 33.6, 1),
		(1, 2, 36, 1),
		(1, 3, 40, 1),
		(1, 4, 40.8, 1),
		(1, 5, 48, 1),
		(1, 6, 100, 1),
		(1, 7, 113.73, 1),
		(1, 8, 73.6, 1),
		(1, 9, 350, 1),
		(1, 10, 278.4, 1),
		(1, 11, 859, 1),
		(1, 12, 17.94, 1),
		(1, 13, 2.5, 1),
		(2, 1, 22, 1),
		(2, 2, 25, 1),
		(2, 3, 15, 1),
		(2, 4, 25, 1),
		(2, 5, 23, 1),
		(2, 6, 156, 1),
		(2, 7, 84, 1),
		(2, 8, 53, 1),
		(2, 9, 360, 1),
		(2, 10, 220, 1),
		(2, 11, 575, 1),
		(2, 12, 9.96, 1),
		(2, 13, 1.3, 1),
		(3, 1, 22, 1),
		(3, 2, 25, 1),
		(3, 3, 15, 1),
		(3, 4, 25, 1),
		(3, 5, 23, 1),
		(3, 6, 156, 1),
		(3, 7, 84, 1),
		(3, 8, 53, 1),
		(3, 9, 360, 1),
		(3, 10, 220, 1),
		(3, 11, 575, 1),
		(3, 12, 9.96, 1),
		(3, 13, 1.3, 1);
	
DROP TABLE IF EXISTS list_menu;
CREATE TABLE list_menu (
	id SERIAL PRIMARY KEY,
	name varchar(100) NOT NULL COMMENT 'Название меню', 
	INDEX (name) COMMENT 'Индекс по названию меню') 
COMMENT = 'Реестр меню';

INSERT INTO list_menu 
VALUES 	(DEFAULT, 'Меню школы'),
		(DEFAULT, 'Меню детского сада'),
		(DEFAULT, 'Меню столовой'),
		(DEFAULT, 'Меню ресторана'),
		(DEFAULT, 'Меню кафе');
	
DROP TABLE IF EXISTS class_dish;
CREATE TABLE class_dish (
	id SERIAL PRIMARY KEY,
	name varchar(100) NOT NULL COMMENT 'Название класса блюд', 
	INDEX (name) COMMENT 'Индекс по названию класса') 
COMMENT = 'Реестр класса блюд';

INSERT INTO class_dish 
VALUES 	(DEFAULT, 'Первые'),
		(DEFAULT, 'Вторые'),
		(DEFAULT, 'Гарниры'),
		(DEFAULT, 'Соусы'),
		(DEFAULT, 'Напитки'),
		(DEFAULT, 'Мучные');

DROP TABLE IF EXISTS menu;
CREATE TABLE menu  (
	id_menu BIGINT UNSIGNED NOT NULL,
	id_class BIGINT UNSIGNED NOT NULL,
	id_ds BIGINT UNSIGNED NOT NULL,
	weihgt_portion FLOAT NOT NULL COMMENT 'Вес одной порции блюда', 
	number_portions INT UNSIGNED NOT NULL COMMENT 'Количество порций',  
	INDEX menu_id_menu (id_menu) COMMENT 'Индекс по меню',
	INDEX menu_id_class (id_class) COMMENT 'Индекс по классам блюд',
	INDEX menu_id_ds (id_ds) COMMENT 'Индекс по блюду',
	CONSTRAINT fk_menu_id_menu FOREIGN KEY (id_menu) REFERENCES list_menu(id),
	CONSTRAINT fk_menu_id_class FOREIGN KEY (id_class) REFERENCES class_dish(id),
	CONSTRAINT fk_menu_id_ds FOREIGN KEY (id_ds) REFERENCES ds(id)
	)	COMMENT = 'Меню';

INSERT INTO menu 
VALUES	(1,1,1,100,1),
		(1,1,2,200,1),
		(1,2,3,300,1),
		(2,1,1,100,1),
		(2,1,2,200,1),
		(2,2,3,300,1),
		(3,1,1,100,1),
		(3,1,2,200,1),
		(3,2,3,200,1),
		(3,2,3,300,1);
	
DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания записи',
  user_name VARCHAR(255) NOT NULL COMMENT 'Имя пользователя',
  table_name VARCHAR(25) NOT NULL COMMENT 'Название таблицы БД',
  id_prim_key BIGINT UNSIGNED NOT NULL COMMENT 'Первичный ключ в таблице'
  ) COMMENT = 'Лог создания записей' ENGINE=ARCHIVE;



