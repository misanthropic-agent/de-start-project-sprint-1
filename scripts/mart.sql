--#идентификатор записи;
--#идентификатор заказчика;
--#Ф. И. О. заказчика;
--#адрес заказчика;
--#дата рождения заказчика;
--#электронная почта заказчика;
--*сумма, которую потратил заказчик;
--*сумма, которую заработала платформа от покупок заказчика за месяц (10% от суммы, которую потратил заказчик);
--*количество заказов у заказчика за месяц;
--*средняя стоимость одного заказа у заказчика за месяц;
--медианное время в днях от момента создания заказа до его завершения за месяц;
--самая популярная категория товаров у этого заказчика за месяц;
--идентификатор самого популярного мастера ручной работы у заказчика. Если заказчик сделал одинаковое количество заказов у нескольких мастеров, возьмите любого;
--количество созданных заказов за месяц;
--количество заказов в процессе изготовки за месяц;
--количество заказов в доставке за месяц;
--количество завершённых заказов за месяц;
--количество незавершённых заказов за месяц;
--отчётный период, год и месяц.

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
WITH agg_customer AS (
  SELECT
    o.customer_id,
    DATE_TRUNC('month', o.order_created_date)::date AS report_period,
    SUM(pr.product_price)       AS customer_spend,
    SUM(pr.product_price) * 0.1 AS platform_income,
    COUNT(o.order_id)           AS count_customer_order,
    AVG(pr.product_price)       AS avg_order_price
  FROM dwh.f_order AS o
  JOIN dwh.d_product pr ON pr.product_id = o.product_id
  GROUP BY o.customer_id, DATE_TRUNC('month', o.order_created_date)
)
category_counts AS (
  SELECT
    customer_id,
    report_period,
    product_type,
    COUNT(*) AS cnt
  FROM base
  GROUP BY customer_id, report_period, product_type
)
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
)
