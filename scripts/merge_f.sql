MERGE INTO dwh.f_order as trg
USING (
    SELECT order_id
)