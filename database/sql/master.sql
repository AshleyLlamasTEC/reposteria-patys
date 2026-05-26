-- Funciones
SOURCE database/sql/functions/helpers/fn_product_stock_available.sql
SOURCE database/sql/functions/pricing/fn_calculate_cart_total.sql
SOURCE database/sql/functions/pricing/fn_calculate_order_total.sql
SOURCE database/sql/functions/orders/fn_generate_order_number.sql

-- Procedimientos
SOURCE database/sql/procedures/cart/sp_add_to_cart.sql
SOURCE database/sql/procedures/cart/sp_remove_from_cart.sql
SOURCE database/sql/procedures/cart/sp_clear_cart.sql
SOURCE database/sql/procedures/orders/sp_create_order.sql
SOURCE database/sql/procedures/orders/sp_update_order_status.sql
SOURCE database/sql/procedures/orders/sp_cancel_order.sql
SOURCE database/sql/procedures/products/sp_update_product_stock.sql

-- Triggers
SOURCE database/sql/triggers/orders/tr_before_insert_order.sql
SOURCE database/sql/triggers/orders/tr_after_update_order.sql
SOURCE database/sql/triggers/cart/tr_after_insert_cart_item.sql
SOURCE database/sql/triggers/cart/tr_after_delete_cart_item.sql
SOURCE database/sql/triggers/cart/tr_after_update_cart_item.sql
SOURCE database/sql/triggers/products/tr_before_update_product.sql
SOURCE database/sql/triggers/audit/tr_after_update_order_status.sql
