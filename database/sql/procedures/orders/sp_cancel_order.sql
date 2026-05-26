DROP PROCEDURE IF EXISTS sp_cancel_order;
DELIMITER $$
CREATE PROCEDURE sp_cancel_order(IN p_order_id BIGINT, IN p_changed_by BIGINT)
BEGIN
    DECLARE v_state VARCHAR(50);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id BIGINT;
    DECLARE v_quantity INT;
    DECLARE cur CURSOR FOR
        SELECT product_id, quantity FROM order_items WHERE order_id = p_order_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    SELECT state INTO v_state FROM orders WHERE id = p_order_id;
    IF v_state IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no existe.';
    END IF;
    IF v_state IN ('cancelled','delivered') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cancelar un pedido ya cancelado o entregado.';
    END IF;
    START TRANSACTION;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_product_id, v_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE products SET stock = stock + v_quantity WHERE id = v_product_id;
    END LOOP;
    CLOSE cur;
    UPDATE orders SET state = 'cancelled', updated_at = NOW() WHERE id = p_order_id;
    -- Trigger de auditoría se encarga
    COMMIT;
END$$
DELIMITER ;
