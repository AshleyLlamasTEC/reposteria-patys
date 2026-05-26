DROP TRIGGER IF EXISTS tr_before_insert_order;
DELIMITER $$
CREATE TRIGGER tr_before_insert_order
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_number IS NULL
        OR NEW.order_number = ''
    THEN
        SET NEW.order_number = fn_generate_order_number();
    END IF;
END$$
DELIMITER ;
