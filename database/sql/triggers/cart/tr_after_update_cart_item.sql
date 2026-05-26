DROP TRIGGER IF EXISTS tr_after_update_cart_item;
DELIMITER $$
CREATE TRIGGER tr_after_update_cart_item
AFTER UPDATE ON cart_items
FOR EACH ROW
BEGIN
    IF NEW.quantity <> OLD.quantity OR NEW.unit_price <> OLD.unit_price THEN
        -- Asegurar que subtotal esté sincronizado
        IF NEW.subtotal <> NEW.quantity * NEW.unit_price THEN
            UPDATE cart_items SET subtotal = NEW.quantity * NEW.unit_price WHERE id = NEW.id;
        END IF;
        UPDATE carts
        SET total_amount = fn_calculate_cart_total(NEW.cart_id),
            updated_at = NOW()
        WHERE id = NEW.cart_id;
    END IF;
END$$
DELIMITER ;
