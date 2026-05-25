-- Genera automáticamente el folio si no se proporciona al insertar un pedido
DROP TRIGGER IF EXISTS tr_before_insert_order;
DELIMITER $$
CREATE TRIGGER tr_before_insert_order
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.folio IS NULL OR NEW.folio = '' THEN
        SET NEW.folio = fn_generate_order_number();
    END IF;
END$$
DELIMITER ;
