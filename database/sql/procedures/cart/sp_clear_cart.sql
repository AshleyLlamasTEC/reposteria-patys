DROP PROCEDURE IF EXISTS sp_clear_cart;
DELIMITER $$
CREATE PROCEDURE sp_clear_cart(IN p_cart_id BIGINT)
BEGIN
    START TRANSACTION;
    DELETE FROM cart_items WHERE cart_id = p_cart_id;
    UPDATE carts SET total_amount = 0.00, updated_at = NOW() WHERE id = p_cart_id;
    COMMIT;
END$$
DELIMITER ;
