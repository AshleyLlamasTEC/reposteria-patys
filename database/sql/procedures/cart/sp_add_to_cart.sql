DROP PROCEDURE IF EXISTS sp_add_to_cart;

DELIMITER $$

CREATE PROCEDURE sp_add_to_cart(
    IN p_user_id BIGINT,
    IN p_product_id BIGINT,
    IN p_quantity INT
)
BEGIN

    DECLARE v_cart_id BIGINT DEFAULT NULL;
    DECLARE v_unit_price DECIMAL(10,2);
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_existing_quantity INT DEFAULT 0;

    /*
    |--------------------------------------------------------------------------
    | Error handler
    |--------------------------------------------------------------------------
    */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    /*
    |--------------------------------------------------------------------------
    | Validar usuario
    |--------------------------------------------------------------------------
    */

    IF p_user_id IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario no autenticado.';

    END IF;

    /*
    |--------------------------------------------------------------------------
    | Obtener producto
    |--------------------------------------------------------------------------
    */

    SELECT
        stock,
        base_price
    INTO
        v_stock,
        v_unit_price
    FROM products
    WHERE id = p_product_id
    LIMIT 1;

    /*
    |--------------------------------------------------------------------------
    | Validar stock
    |--------------------------------------------------------------------------
    */

    IF v_stock < p_quantity THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente.';

    END IF;

    START TRANSACTION;

    /*
    |--------------------------------------------------------------------------
    | Buscar carrito activo
    |--------------------------------------------------------------------------
    */

    SELECT id
    INTO v_cart_id
    FROM carts
    WHERE user_id = p_user_id
    AND status = 'active'
    LIMIT 1;

    /*
    |--------------------------------------------------------------------------
    | Crear carrito si no existe
    |--------------------------------------------------------------------------
    */

    IF v_cart_id IS NULL THEN

        INSERT INTO carts (
            user_id,
            status,
            total_amount,
            created_at,
            updated_at
        )
        VALUES (
            p_user_id,
            'active',
            0.00,
            NOW(),
            NOW()
        );

        SET v_cart_id = LAST_INSERT_ID();

    END IF;

    /*
    |--------------------------------------------------------------------------
    | Verificar si ya existe item
    |--------------------------------------------------------------------------
    */

    SELECT quantity
    INTO v_existing_quantity
    FROM cart_items
    WHERE cart_id = v_cart_id
    AND product_id = p_product_id
    LIMIT 1;

    /*
    |--------------------------------------------------------------------------
    | Actualizar item existente
    |--------------------------------------------------------------------------
    */

    IF v_existing_quantity > 0 THEN

        UPDATE cart_items
        SET
            quantity = quantity + p_quantity,
            subtotal = (quantity + p_quantity) * unit_price,
            updated_at = NOW()
        WHERE cart_id = v_cart_id
        AND product_id = p_product_id;

    ELSE

        /*
        |--------------------------------------------------------------------------
        | Insertar nuevo item
        |--------------------------------------------------------------------------
        */

        INSERT INTO cart_items (
            cart_id,
            product_id,
            quantity,
            unit_price,
            subtotal,
            created_at,
            updated_at
        )
        VALUES (
            v_cart_id,
            p_product_id,
            p_quantity,
            v_unit_price,
            (p_quantity * v_unit_price),
            NOW(),
            NOW()
        );

    END IF;

    /*
    |--------------------------------------------------------------------------
    | Recalcular total carrito
    |--------------------------------------------------------------------------
    */

    UPDATE carts
    SET
        total_amount = (
            SELECT COALESCE(SUM(subtotal), 0)
            FROM cart_items
            WHERE cart_id = v_cart_id
        ),
        updated_at = NOW()
    WHERE id = v_cart_id;

    COMMIT;

END$$

DELIMITER ;
