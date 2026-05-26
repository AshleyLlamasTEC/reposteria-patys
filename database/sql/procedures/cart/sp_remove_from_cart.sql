DROP PROCEDURE IF EXISTS sp_remove_from_cart;
DELIMITER $$
CREATE PROCEDURE sp_remove_from_cart(IN p_cart_item_id BIGINT)
BEGIN
    DECLARE v_cart_id BIGINT;
    SELECT cart_id INTO v_cart_id FROM cart_items WHERE id = p_cart_item_id;
    IF v_cart_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ítem del carrito no existe.';
    END IF;
    START TRANSACTION;
    DELETE FROM cart_items WHERE id = p_cart_item_id;
    -- El total se actualiza vía trigger
    COMMIT;
END$$
DELIMITER ;
