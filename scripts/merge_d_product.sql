MERGE INTO dwh.d_product AS trg
USING (SELECT DISTINCT product_namщe, product_description, product_type, product_price FROM tmp_ext_src) AS src
ON trg.product_name = src.product_name 
    AND trg.product_description = src.product_description
    AND trg.product_price = src.product_price
WHEN MATCHED
THEN UPDATE SET
    product_type = src.product_type,
    load_dttm = CURRENT_TIMESTAMP
WHEN NOT MATCHED 
    THEN INSERT
    (
        product_name,
        product_description,
        product_type,
        product_price,
        load_dttm
    ) VALUES (
        src.product_name,
        src.product_description,
        src.product_type,
        src.product_price,
        CURRENT_TIMESTAMP
    );

