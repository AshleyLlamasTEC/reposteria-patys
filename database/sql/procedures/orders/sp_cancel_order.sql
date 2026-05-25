-- Cancela un pedido, restaura stock y registra auditoría
DROP PROCEDURE IF EXISTS sp_cancel_order;
DELIMITER $$
CREATE PROCEDURE sp_cancel_order(
    IN p_order_id BIGINT,
    IN p_changed_by BIGINT
)
BEGIN
    DECLARE v_status VARCHAR(50);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id BIGINT;
    DECLARE v_quantity INT;
    DECLARE cur CURSOR FOR
        SELECT product_id, quantity FROM order_items WHERE order_id = p_order_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Obtener estado actual
    SELECT status INTO v_status FROM orders WHERE id = p_order_id;
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no existe.';
    END IF;

    IF v_status IN ('cancelled','delivered') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden cancelar pedidos que no estén cancelados ni entregados.';
    END IF;

    START TRANSACTION;

    -- Recorrer items y restaurar stock
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_product_id, v_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE products SET stock = stock + v_quantity WHERE id = v_product_id;
    END LOOP;
    CLOSE cur;

    -- Cambiar estado a cancelado
    UPDATE orders SET status = 'cancelled', updated_at = NOW() WHERE id = p_order_id;

    -- Registrar auditoría
    INSERT INTO audit_orders (order_id, old_status, new_status, changed_by, changed_at)
    VALUES (p_order_id, v_status, 'cancelled', p_changed_by, NOW());

    COMMIT;
END$$
DELIMITER ;
