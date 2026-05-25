-- Función para verificar disponibilidad de stock para un producto
DROP FUNCTION IF EXISTS fn_product_stock_available;
DELIMITER $$
CREATE FUNCTION fn_product_stock_available(p_product_id BIGINT, p_quantity INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE stock_available BOOLEAN DEFAULT FALSE;
    DECLARE current_stock INT DEFAULT 0;

    -- Obtener el stock actual del producto
    SELECT stock INTO current_stock
    FROM products
    WHERE id = p_product_id;

    IF current_stock >= p_quantity THEN
        SET stock_available = TRUE;
    END IF;

    RETURN stock_available;
END$$
DELIMITER ;
