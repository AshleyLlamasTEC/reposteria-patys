-- Elimina un ítem del carrito y actualiza el total
DROP PROCEDURE IF EXISTS sp_remove_from_cart;
DELIMITER $$
CREATE PROCEDURE sp_remove_from_cart(IN p_cart_item_id BIGINT)
BEGIN
    DECLARE v_cart_id BIGINT;

    -- Obtener el carrito asociado al ítem
    SELECT cart_id INTO v_cart_id
    FROM cart_items
    WHERE id = p_cart_item_id;

    IF v_cart_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ítem del carrito no existe.';
    END IF;

    START TRANSACTION;

    DELETE FROM cart_items WHERE id = p_cart_item_id;

    -- Recalcular total del carrito
    UPDATE carts
    SET total = fn_calculate_cart_total(v_cart_id),
        updated_at = NOW()
    WHERE id = v_cart_id;

    COMMIT;
END$$
DELIMITER ;
