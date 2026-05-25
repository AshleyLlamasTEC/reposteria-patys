-- Calcula el total del carrito sumando cantidad * precio unitario
DROP FUNCTION IF EXISTS fn_calculate_cart_total;
DELIMITER $$
CREATE FUNCTION fn_calculate_cart_total(p_cart_id BIGINT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0.00;

    SELECT COALESCE(SUM(ci.quantity * ci.unit_price), 0.00)
    INTO total
    FROM cart_items ci
    WHERE ci.cart_id = p_cart_id;

    RETURN total;
END$$
DELIMITER ;
