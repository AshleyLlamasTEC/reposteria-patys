DROP PROCEDURE IF EXISTS sp_update_product_stock;
DELIMITER $$
CREATE PROCEDURE sp_update_product_stock(
    IN p_product_id BIGINT,
    IN p_quantity_change INT
)
BEGIN
    DECLARE new_stock INT;
    START TRANSACTION;
    SELECT stock + p_quantity_change INTO new_stock
    FROM products WHERE id = p_product_id FOR UPDATE;
    IF new_stock < 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente. No se permite stock negativo.';
    END IF;
    UPDATE products SET stock = new_stock WHERE id = p_product_id;
    COMMIT;
END$$
DELIMITER ;
