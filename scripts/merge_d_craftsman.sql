MERGE INTO dwh.d_craftsman AS trg
USING (SELECT DISTINCT
    craftsman_name, craftsman_address, craftsman_birthday, craftsman_email
    FROM tmp_ext_src
    ) as src
ON trg.craftsman_name = src.craftsman_name AND trg.craftsman_email =  src.craftsman_email
WHEN MATCHED THEN
  UPDATE SET craftsman_address = src.craftsman_address,
             craftsman_birthday = src.craftsman_birthday,
             load_dttm = current_timestamp
WHEN NOT MATCHED THEN
  INSERT (
    craftsman_name,
    craftsman_address,
    craftsman_birthday,
    craftsman_email,
    load_dttm
    )
  VALUES (
    src.craftsman_name,
    src.craftsman_address,
    src.craftsman_birthday,
    src.craftsman_email,
    current_timestamp
    );
