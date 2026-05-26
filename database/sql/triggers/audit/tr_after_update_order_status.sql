DROP TRIGGER IF EXISTS tr_after_update_order_status;
DELIMITER $$
CREATE TRIGGER tr_after_update_order_status
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.state <> OLD.state THEN
        INSERT INTO audit_orders (order_id, old_state, new_state, changed_by, changed_at)
        VALUES (NEW.id, OLD.state, NEW.state, @current_user_id, NOW());
    END IF;
END$$
DELIMITER ;
