-- Registra en auditoría cada cambio de estado de pedido usando el usuario de sesión
DROP TRIGGER IF EXISTS tr_after_update_order_status;
DELIMITER $$
CREATE TRIGGER tr_after_update_order_status
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status <> OLD.status THEN
        INSERT INTO audit_orders (order_id, old_status, new_status, changed_by, changed_at)
        VALUES (NEW.id, OLD.status, NEW.status, @current_user_id, NOW());
    END IF;
END$$
DELIMITER ;
