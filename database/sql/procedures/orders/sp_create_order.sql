-- Crea un pedido a partir del carrito activo del usuario
-- Genera folio, mueve items, actualiza stock y cambia estado del carrito
DROP PROCEDURE IF EXISTS sp_create_order;
DELIMITER $$
CREATE PROCEDURE sp_create_order(IN p_user_id BIGINT)
BEGIN
    DECLARE v_cart_id BIGINT;
    DECLARE v_order_id BIGINT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_folio VARCHAR(20);
    DECLARE v_has_items BOOLEAN DEFAULT FALSE;

    -- Validar existencia de carrito activo
    SELECT id, total INTO v_cart_id, v_total
    FROM carts
    WHERE user_id = p_user_id AND status = 'active'
    LIMIT 1;

    IF v_cart_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay un carrito activo para este usuario.';
    END IF;

    -- Verificar que el carrito tenga items
    SELECT EXISTS(SELECT 1 FROM cart_items WHERE cart_id = v_cart_id) INTO v_has_items;
    IF NOT v_has_items THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El carrito está vacío. Agrega productos antes de crear el pedido.';
    END IF;

    -- Validar stock de cada item
    IF EXISTS(
        SELECT 1
        FROM cart_items ci
        JOIN products p ON p.id = ci.product_id
        WHERE ci.cart_id = v_cart_id
        AND p.stock < ci.quantity
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Algunos productos no tienen stock suficiente.';
    END IF;

    START TRANSACTION;

    -- Generar folio
    SET v_folio = fn_generate_order_number();

    -- Crear la orden
    INSERT INTO orders (user_id, folio, status, total, created_at, updated_at)
    VALUES (p_user_id, v_folio, 'pending', v_total, NOW(), NOW());
    SET v_order_id = LAST_INSERT_ID();

    -- Mover cart_items a order_items y descontar stock
    INSERT INTO order_items (order_id, product_id, quantity, unit_price, created_at, updated_at)
    SELECT v_order_id, ci.product_id, ci.quantity, ci.unit_price, NOW(), NOW()
    FROM cart_items ci
    WHERE ci.cart_id = v_cart_id;

    -- Actualizar stock de productos
    UPDATE products p
    JOIN cart_items ci ON p.id = ci.product_id
    SET p.stock = p.stock - ci.quantity
    WHERE ci.cart_id = v_cart_id;

    -- Vaciar carrito y marcarlo como convertido
    DELETE FROM cart_items WHERE cart_id = v_cart_id;
    UPDATE carts
    SET status = 'converted', total = 0.00, updated_at = NOW()
    WHERE id = v_cart_id;

    COMMIT;
END$$
DELIMITER ;
