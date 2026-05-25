-- Recalcula el total del carrito al eliminar un ítem
DROP TRIGGER IF EXISTS tr_after_delete_cart_item;
DELIMITER $$
CREATE TRIGGER tr_after_delete_cart_item
AFTER DELETE ON cart_items
FOR EACH ROW
BEGIN
    -- Verificar que el carrito aún existe (por integridad)
    IF EXISTS(SELECT 1 FROM carts WHERE id = OLD.cart_id) THEN
        UPDATE carts
        SET total = fn_calculate_cart_total(OLD.cart_id),
            updated_at = NOW()
        WHERE id = OLD.cart_id;
    END IF;
END$$
DELIMITER ;
