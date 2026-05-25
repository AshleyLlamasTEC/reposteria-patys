-- Recalcula el total del carrito al insertar un ítem
DROP TRIGGER IF EXISTS tr_after_insert_cart_item;
DELIMITER $$
CREATE TRIGGER tr_after_insert_cart_item
AFTER INSERT ON cart_items
FOR EACH ROW
BEGIN
    UPDATE carts
    SET total = fn_calculate_cart_total(NEW.cart_id),
        updated_at = NOW()
    WHERE id = NEW.cart_id;
END$$
DELIMITER ;
