USE recipe;
/* 7. представления (минимум 2); */

/* 7.1. Создать предствление состава блюд */
CREATE OR REPLACE VIEW view_sostav_blud AS
SELECT d.id AS ds_id, d.name AS ds_name, p.id AS product_id, p.name AS product_name, z.brutto AS brutto, z.netto AS netto FROM zakladki z
JOIN ds d ON z.id_ds = d.id
JOIN products p ON z.id_product = p.id;

SELECT * FROM view_sostav_blud ORDER BY ds_id;

/* 7.2. Создать представление энергетической ценности блюд по закладке */
CREATE OR REPLACE VIEW view_energy_blud AS
SELECT 	d.id, d.name,
		ROUND(sum(z.netto*p.prot)*4+sum(z.netto*p.fat)*9+sum(z.netto*p.carb)*4) AS energy
FROM zakladki z 
JOIN ds d ON z.id_ds = d.id 
JOIN products p ON z.id_product = p.id
GROUP BY d.id;

/* 6. Cкрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы) */

/* 6.1. Запрос возвращает стоимость продуктов по определенному прайсу с учетом сезонного коэффициента*/
SELECT  p.name, 
CASE 
	WHEN MONTH(curdate()) IN (12,1,2) THEN FORMAT(p.k1*pc.product_price*pc.coeff_price, 2)
 	WHEN MONTH(curdate()) IN (3,4,5) THEN FORMAT (p.k2*pc.product_price*pc.coeff_price, 2)
 	WHEN MONTH(curdate()) IN (6,7,8) THEN FORMAT (p.k3*pc.product_price*pc.coeff_price, 2)
 	WHEN MONTH(curdate()) IN (9,10,11) THEN FORMAT (p.k4*pc.product_price*pc.coeff_price, 2)
END AS product_price
FROM prices pc 
JOIN products p ON pc.id_product = p.id 
WHERE pc.id_list_prices = 1
ORDER BY p.name;

/* Запрос возвращает состав блюда по брутто, нетто */
SELECT d.name, p.name, z.brutto, z.netto FROM zakladki z
JOIN ds d ON z.id_ds = d.id
JOIN products p ON z.id_product = p.id 
WHERE id_ds = 1;

/* Запрос возвращает стоимость блюд по закладке по выбранному прайсу*/
SELECT vsb.ds_name, ROUND(sum(vsb.brutto*p.product_price*p.coeff_price),2) AS cost FROM prices p 
JOIN list_prices lp  ON p.id_list_prices = lp.id  
JOIN view_sostav_blud vsb ON p.id_product = vsb.product_id 
WHERE lp.id = 3
GROUP BY vsb.ds_id;


/* 8. Хранимые процедуры,  триггеры;*/
SELECT SubString(USER(), 1, InStr(User(), '@')-1);
SELECT USER();

-- Создать процедуру создания прайса копированием из существующего

DROP PROCEDURE IF EXISTS copy_price;

DELIMITER &&


CREATE PROCEDURE copy_price(price_name VARCHAR(100), price_id BIGINT UNSIGNED, OUT tran_result VARCHAR(200))
BEGIN
	DECLARE tran_rollback BOOL DEFAULT 0;
	DECLARE code VARCHAR(100);
	DECLARE error_string VARCHAR(100);


	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	-- обработка ошибок
	BEGIN
		SET tran_rollback = 1;
	
		GET STACKED DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		SET tran_result = CONCAT(code, ': ', error_string);
	END;
	
	-- запускаем транзакцию добавления нового прайса
	START TRANSACTION; 

	INSERT INTO list_prices(name)
	VALUES (price_name);
	
	INSERT INTO prices (id_list_prices, id_product, product_price, coeff_price)
	SELECT LAST_INSERT_ID(), id_product, product_price, coeff_price  FROM prices 
	WHERE id_list_prices = price_id;
	
	-- если была получена ошибка откатываем изменения
	IF tran_rollback 
	THEN 
		ROLLBACK;
	ELSE
	-- если записи добавлены, выводим ок
		SET tran_result = 'ok';
	-- успешно завершаем транзакцию
		COMMIT;
	END IF;	
END&&

DELIMITER ;

-- Вызвать процедуру
CALL copy_price('Новый прайс', 3, @tran_result);


-- Создать триггер при обновлении т. Zakladki записываются в т. Logs данные пользователя
DROP TRIGGER IF EXISTS after_zakladki_update;

DELIMITER $$

CREATE TRIGGER after_zakladki_update
AFTER UPDATE 
ON zakladki FOR EACH ROW
BEGIN
    INSERT INTO logs(created_at, user_name, table_name, id_prim_key)
        VALUES(CURRENT_TIMESTAMP, USER(), 'zakladki', new.id_ds);
END$$

DELIMITER ;

DROP TRIGGER IF EXISTS after_catalogs_insert;

DELIMITER $$ 

-- Обновить запись в т. Zakladki 
UPDATE zakladki SET netto = 0.015
WHERE id_ds =3 AND id_product =10;

SELECT * FROM logs;
