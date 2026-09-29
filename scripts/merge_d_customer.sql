MERGE INTO dwh.d_customer AS trg
USING (SELECT DISTINCT customer_name, customer_address, customer_birthday, customer_email FROM tmp_ext_src) AS src
ON trg.customer_name = src.customer_name AND trg.customer_email = src.customer_email
WHEN MATCHED 
    THEN UPDATE SET 
        customer_address = src.customer_address,
        customer_birthday = src.customer_birthday,
        load_dttm = CURRENT_TIMESTAMP
WHEN NOT MATCHED
    THEN INSERT
        (
            customer_name,
            customer_address,
            customer_birthday, 
            customer_email,
            load_dttm
        ) VALUES
        (
            src.customer_name,
            src.customer_address,
            src.customer_birthday, 
            src.customer_email,
            CURRENT_TIMESTAMP
        );