DROP TRIGGER IF EXISTS tr_after_update_cart_item;

DELIMITER $$

CREATE TRIGGER tr_after_update_cart_item

AFTER UPDATE ON cart_items

FOR EACH ROW

BEGIN

    /*
    |--------------------------------------------------------------------------
    | Recalcular total del carrito
    |--------------------------------------------------------------------------
    */

    UPDATE carts

    SET total_amount = (

        SELECT COALESCE(SUM(subtotal), 0)

        FROM cart_items

        WHERE cart_id = NEW.cart_id

    )

    WHERE id = NEW.cart_id;

END$$

DELIMITER ;
