DROP TRIGGER IF EXISTS tr_after_update_order;
DELIMITER $$
CREATE TRIGGER tr_after_update_order
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Placeholder: lógica futura de notificaciones, etc.
END$$
DELIMITER ;
