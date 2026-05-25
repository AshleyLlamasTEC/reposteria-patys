-- Genera un folio con formato PATY-YYYYMMDD-0001
-- Para alta concurrencia se recomienda usar una tabla de secuencias y GET_LOCK
DROP FUNCTION IF EXISTS fn_generate_order_number;
DELIMITER $$
CREATE FUNCTION fn_generate_order_number()
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE today_str CHAR(8);
    DECLARE max_num INT DEFAULT 0;
    DECLARE new_folio VARCHAR(20);

    SET today_str = DATE_FORMAT(NOW(), '%Y%m%d');

    -- Obtener el último número usado hoy
    SELECT MAX(CAST(SUBSTRING_INDEX(folio, '-', -1) AS UNSIGNED))
    INTO max_num
    FROM orders
    WHERE folio LIKE CONCAT('PATY-', today_str, '-%');

    SET max_num = COALESCE(max_num, 0) + 1;

    SET new_folio = CONCAT('PATY-', today_str, '-', LPAD(max_num, 4, '0'));

    RETURN new_folio;
END$$
DELIMITER ;
