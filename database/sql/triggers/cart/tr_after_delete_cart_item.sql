DROP TRIGGER IF EXISTS tr_after_delete_cart_item;

DELIMITER $$

CREATE TRIGGER tr_after_delete_cart_item

AFTER DELETE ON cart_items

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

        WHERE cart_id = OLD.cart_id

    )

    WHERE id = OLD.cart_id;

END$$

DELIMITER ;
