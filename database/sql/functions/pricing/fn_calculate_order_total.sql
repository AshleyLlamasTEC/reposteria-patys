-- Calcula el total de una orden basado en sus items
DROP FUNCTION IF EXISTS fn_calculate_order_total;
DELIMITER $$
CREATE FUNCTION fn_calculate_order_total(p_order_id BIGINT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0.00;

    SELECT COALESCE(SUM(oi.quantity * oi.unit_price), 0.00)
    INTO total
    FROM order_items oi
    WHERE oi.order_id = p_order_id;

    RETURN total;
END$$
DELIMITER ;
