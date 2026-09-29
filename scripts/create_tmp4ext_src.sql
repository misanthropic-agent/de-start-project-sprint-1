DROP TABLE IF EXISTS tmp_ext_src;
CREATE TEMP TABLE tmp_ext_src AS 
SELECT
  o.order_id,
  o.order_created_date,
  o.order_completion_date,
  o.order_status,
  o.craftsman_id,
  o.craftsman_name,
  o.craftsman_address,
  o.craftsman_birthday,
  o.craftsman_email,
  o.product_id,
  o.product_name,
  o.product_price,
  o.product_description,
  o.product_type,
  c.customer_id,
  c.customer_name,
  c.customer_address,
  c.customer_birthday,
  c.customer_email,
FROM external_source.craft_products_orders o
JOIN external_source.customers c ON c.customer_id = o.customer_id;
SELECT COUNT(*) FROM tmp_ext_src;

