DROP TABLE IF EXISTS tmp_src_f;
CREATE TEMP TABLE tmp_src_f AS
SELECT  dp.product_id,              
        dc.craftsman_id,            
        dcust.customer_id,          
        src.order_created_date,
        src.order_completion_date,
        src.order_status,
        current_timestamp AS load_dttm
FROM tmp_ext_src src
JOIN dwh.d_craftsman dc
    ON dc.craftsman_name = src.craftsman_name
   AND dc.craftsman_email = src.craftsman_email
JOIN dwh.d_customer dcust
    ON dcust.customer_name = src.customer_name
   AND dcust.customer_email = src.customer_email
JOIN dwh.d_product dp
    ON dp.product_name = src.product_name
   AND dp.product_description = src.product_description
   AND dp.product_price = src.product_price;