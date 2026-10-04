UPDATE dwh.f_order
SET order_status = 'in-progress',
    load_dttm = CURRENT_TIMESTAMP
WHERE order_status = 'in progress';