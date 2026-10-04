--идентификатор записи;
--идентификатор заказчика;
--Ф. И. О. заказчика;
--адрес заказчика;
--дата рождения заказчика;
--электронная почта заказчика;
--сумма, которую потратил заказчик;
--сумма, которую заработала платформа от покупок заказчика за месяц (10% от суммы, которую потратил заказчик);
--количество заказов у заказчика за месяц;
--средняя стоимость одного заказа у заказчика за месяц;
--медианное время в днях от момента создания заказа до его завершения за месяц;
--самая популярная категория товаров у этого заказчика за месяц;
--идентификатор самого популярного мастера ручной работы у заказчика. Если заказчик сделал одинаковое количество заказов у нескольких мастеров, возьмите любого;
--количество созданных заказов за месяц;
--количество заказов в процессе изготовки за месяц;
--количество заказов в доставке за месяц;
--количество завершённых заказов за месяц;
--количество незавершённых заказов за месяц;
--отчётный период, год и месяц.

DROP TABLE IF EXISTS dwh.customer_report_datamart;

CREATE TABLE dwh.customer_report_datamart AS
WITH base AS (
  SELECT
    o.order_id,
    o.customer_id,
    o.craftsman_id,
    o.order_status,
    o.order_created_date,
    o.order_completion_date,
    p.product_price,
    p.product_type,
    DATE_TRUNC('month', o.order_created_date)::date AS report_period
  FROM dwh.f_order o
  JOIN dwh.d_product p ON p.product_id = o.product_id
),

agg_customer AS (
  SELECT
    customer_id,
    report_period,
    SUM(product_price) AS customer_spend,
    SUM(product_price) * 0.1 AS platform_income,
    COUNT(*) AS count_customer_order,
    AVG(product_price) AS avg_order_price,
    percentile_cont(0.5) WITHIN GROUP (
      ORDER BY (order_completion_date::date - order_created_date::date)
    ) FILTER (WHERE order_status = 'done') AS median_days_to_complete,
    COUNT(*) FILTER (WHERE order_status = 'created') AS count_order_created,
    COUNT(*) FILTER (WHERE order_status = 'in-progress') AS count_order_in_progress,
    COUNT(*) FILTER (WHERE order_status = 'delivery') AS count_order_delivery,
    COUNT(*) FILTER (WHERE order_status = 'done') AS count_order_done,
    COUNT(*) FILTER (WHERE order_status <> 'done') AS count_order_not_done
  FROM base
  GROUP BY customer_id, report_period
),

category_counts AS (
  SELECT
    customer_id, report_period, product_type, COUNT(*) AS cnt
  FROM base
  GROUP BY customer_id, report_period, product_type
),

top_category AS (
  SELECT
    customer_id,
    report_period,
    product_type AS top_product_category
  FROM (
    SELECT
      customer_id,
      report_period,
      product_type,
      row_number() OVER (
        PARTITION BY customer_id, report_period
        ORDER BY cnt DESC, product_type
      ) AS rn
    FROM category_counts
  ) t
  WHERE rn = 1
),

craftsman_counts AS (
  SELECT
    customer_id, report_period, craftsman_id, COUNT(*) AS cnt
  FROM base
  GROUP BY customer_id, report_period, craftsman_id
),

top_craftsman AS (
  SELECT
    customer_id, report_period, craftsman_id AS top_craftsman_id
  FROM (
    SELECT
      customer_id, report_period, craftsman_id, 
      row_number() OVER (
        PARTITION BY customer_id, report_period
        ORDER BY cnt DESC, craftsman_id
      ) AS rn
    FROM craftsman_counts
  ) t
  WHERE rn = 1
)

SELECT
  row_number() OVER (ORDER BY a.report_period, a.customer_id) AS id,
  a.customer_id,
  c.customer_name,
  c.customer_address,
  c.customer_birthday,
  c.customer_email,
  ROUND(a.customer_spend, 2) AS customer_spend,
  ROUND(a.platform_income, 2) AS platform_income,
  a.count_customer_order,
  ROUND(a.avg_order_price, 2) AS avg_order_price,
  ROUND(a.median_days_to_complete::numeric, 1) AS median_days_to_complete,
  tc.top_product_category,
  tm.top_craftsman_id,
  a.count_order_created,
  a.count_order_in_progress,
  a.count_order_delivery,
  a.count_order_done,
  a.count_order_not_done,
  a.report_period
FROM agg_customer a
JOIN dwh.d_customer c ON c.customer_id = a.customer_id
JOIN top_category tc  ON tc.customer_id = a.customer_id AND tc.report_period = a.report_period
JOIN top_craftsman tm ON tm.customer_id = a.customer_id AND tm.report_period = a.report_period;

