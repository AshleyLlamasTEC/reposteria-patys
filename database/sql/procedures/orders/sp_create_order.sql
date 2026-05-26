DROP PROCEDURE IF EXISTS sp_create_order;
DELIMITER $$
CREATE PROCEDURE sp_create_order(IN p_user_id BIGINT)
BEGIN
    DECLARE v_cart_id BIGINT;
    DECLARE v_order_id BIGINT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_folio VARCHAR(20);
    -- Buscar carrito activo con items
    SELECT c.id, c.total_amount INTO v_cart_id, v_total
    FROM carts c
    WHERE c.user_id = p_user_id AND c.status = 'active'
    LIMIT 1;
    IF v_cart_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay un carrito activo.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM cart_items WHERE cart_id = v_cart_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El carrito está vacío.';
    END IF;
    -- Validar stock de todos los items
    IF EXISTS(
        SELECT 1 FROM cart_items ci
        JOIN products p ON p.id = ci.product_id
        WHERE ci.cart_id = v_cart_id AND p.stock < ci.quantity
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Algunos productos no tienen stock suficiente.';
    END IF;
    START TRANSACTION;
    SET v_folio = fn_generate_order_number();
    INSERT INTO orders (user_id, folio, state, total_amount, created_at, updated_at)
    VALUES (p_user_id, v_folio, 'pending', v_total, NOW(), NOW());
    SET v_order_id = LAST_INSERT_ID();
    -- Mover items de carrito a orden
    INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal, created_at, updated_at)
    SELECT v_order_id, ci.product_id, ci.quantity, ci.unit_price, ci.subtotal, NOW(), NOW()
    FROM cart_items ci WHERE ci.cart_id = v_cart_id;
    -- Descontar stock
    UPDATE products p
    JOIN cart_items ci ON p.id = ci.product_id
    SET p.stock = p.stock - ci.quantity
    WHERE ci.cart_id = v_cart_id;
    -- Vaciar carrito y cambiar estado a converted
    DELETE FROM cart_items WHERE cart_id = v_cart_id;
    UPDATE carts SET status = 'converted', total_amount = 0.00, updated_at = NOW() WHERE id = v_cart_id;
    COMMIT;
END$$
DELIMITER ;
