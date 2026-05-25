-- Cambia el estado de un pedido validando transiciones permitidas
-- Registra cambio en production_stages si corresponde y en auditoría
DROP PROCEDURE IF EXISTS sp_update_order_status;
DELIMITER $$
CREATE PROCEDURE sp_update_order_status(
    IN p_order_id BIGINT,
    IN p_new_status VARCHAR(50),
    IN p_changed_by BIGINT -- ID del usuario que realiza el cambio
)
BEGIN
    DECLARE v_old_status VARCHAR(50);
    DECLARE v_allowed BOOLEAN DEFAULT FALSE;

    -- Obtener estado actual
    SELECT status INTO v_old_status FROM orders WHERE id = p_order_id;
    IF v_old_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no existe.';
    END IF;

    -- Validar transiciones de estado (reglas de negocio)
    SET v_allowed =
        CASE
            WHEN v_old_status = 'pending' AND p_new_status IN ('approved','cancelled') THEN TRUE
            WHEN v_old_status = 'approved' AND p_new_status = 'in_production' THEN TRUE
            WHEN v_old_status = 'in_production' AND p_new_status = 'ready' THEN TRUE
            WHEN v_old_status = 'ready' AND p_new_status = 'delivered' THEN TRUE
            ELSE FALSE
        END;

    IF NOT v_allowed THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('No se permite transitar de ', v_old_status, ' a ', p_new_status);
    END IF;

    START TRANSACTION;

    -- Actualizar el estado
    UPDATE orders SET status = p_new_status, updated_at = NOW() WHERE id = p_order_id;

    -- Si pasa a producción, crear registro en production_stages
    IF p_new_status = 'in_production' THEN
        INSERT INTO production_stages (order_id, stage, created_at)
        VALUES (p_order_id, 'queued', NOW());
    END IF;

    -- Registrar en auditoría
    INSERT INTO audit_orders (order_id, old_status, new_status, changed_by, changed_at)
    VALUES (p_order_id, v_old_status, p_new_status, p_changed_by, NOW());

    COMMIT;
END$$
DELIMITER ;
