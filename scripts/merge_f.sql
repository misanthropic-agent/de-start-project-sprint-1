MERGE INTO dwh.f_order as trg
USING tmp_src_f AS src
ON  trg.product_id = src.product_id AND
    trg.craftsman_id = src.craftsman_id AND
    trg.customer_id = src.customer_id AND
    trg.order_created_date = src.order_created_date
WHEN MATCHED
    THEN UPDATE SET
        order_completion_date = src.order_completion_date,
        order_status = src.order_status,
        load_dttm = CURRENT_TIMESTAMP
WHEN NOT MATCHED
    THEN INSERT (
        product_id,
        craftsman_id,
        customer_id,
        order_created_date,
        order_completion_date,
        order_status,   
        load_dttm
    ) VALUES (
        src.product_id,
        src.craftsman_id,
        src.customer_id,
        src.order_created_date,
        src.order_completion_date,
        src.order_status,
        CURRENT_TIMESTAMP
    );