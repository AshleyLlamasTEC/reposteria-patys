-- Agrega un producto al carrito del usuario (crea uno si no tiene activo)
-- Valida stock y evita duplicados
DROP PROCEDURE IF EXISTS sp_add_to_cart;
DELIMITER $$
CREATE PROCEDURE sp_add_to_cart(
    IN p_user_id BIGINT,
    IN p_product_id BIGINT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_cart_id BIGINT;
    DECLARE v_stock_available BOOLEAN;
    DECLARE v_unit_price DECIMAL(10,2);
    DECLARE v_existing_item_id BIGINT DEFAULT NULL;

    -- Validar stock
    SELECT fn_product_stock_available(p_product_id, p_quantity) INTO v_stock_available;
    IF NOT v_stock_available THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para agregar al carrito.';
    END IF;

    -- Obtener precio del producto
    SELECT price INTO v_unit_price FROM products WHERE id = p_product_id;

    -- Iniciar transacción
    START TRANSACTION;

    -- Buscar o crear carrito activo del usuario
    SELECT id INTO v_cart_id FROM carts
    WHERE user_id = p_user_id AND status = 'active' LIMIT 1;

    IF v_cart_id IS NULL THEN
        INSERT INTO carts (user_id, status, total, created_at, updated_at)
        VALUES (p_user_id, 'active', 0.00, NOW(), NOW());
        SET v_cart_id = LAST_INSERT_ID();
    END IF;

    -- Verificar si el producto ya existe en el carrito
    SELECT id INTO v_existing_item_id
    FROM cart_items
    WHERE cart_id = v_cart_id AND product_id = p_product_id
    LIMIT 1;

    IF v_existing_item_id IS NOT NULL THEN
        -- Actualizar cantidad y evitar duplicados
        UPDATE cart_items
        SET quantity = quantity + p_quantity,
            updated_at = NOW()
        WHERE id = v_existing_item_id;
    ELSE
        -- Insertar nuevo item
        INSERT INTO cart_items (cart_id, product_id, quantity, unit_price, created_at, updated_at)
        VALUES (v_cart_id, p_product_id, p_quantity, v_unit_price, NOW(), NOW());
    END IF;

    -- Recalcular total del carrito (función lo actualiza)
    UPDATE carts
    SET total = fn_calculate_cart_total(v_cart_id),
        updated_at = NOW()
    WHERE id = v_cart_id;

    COMMIT;
END$$
DELIMITER ;
