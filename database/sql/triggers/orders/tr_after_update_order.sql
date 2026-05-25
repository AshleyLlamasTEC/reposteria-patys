-- Placeholder para lógica post-actualización de pedidos (ej.: invalidar caché)
DROP TRIGGER IF EXISTS tr_after_update_order;
DELIMITER $$
CREATE TRIGGER tr_after_update_order
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- En futuras implementaciones se puede notificar a servicios externos
    -- Por ahora no se ejecuta ninguna acción adicional
END$$
DELIMITER ;
