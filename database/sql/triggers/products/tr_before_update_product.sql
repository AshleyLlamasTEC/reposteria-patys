DROP TRIGGER IF EXISTS tr_before_update_product;
DELIMITER $$
CREATE TRIGGER tr_before_update_product
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite stock negativo.';
    END IF;
END$$
DELIMITER ;
