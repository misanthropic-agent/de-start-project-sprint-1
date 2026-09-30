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

SELECT 
  o.order_id,
  o.customer_id,
  o.craftsman_id,
  cr.customer_name,
  cr.customer_address,
  cr.customer_birthday,
  cr.customer_email,
  SUM(pr.product_price) OVER (PARTITION BY o.customer_id) as agg_sum_by_client,
  (SUM(pr.product_price) OVER (PARTITION BY o.customer_id, o.order_created_date)) * 0.1 
      as agg_revenue_by_client,
  COUNT(*) OVER (PARTITION BY o.customer_id, o.order_created_date) as agg_count_by_client
  
FROM dwh.f_order o
JOIN dwh.d_craftsman cm ON cm.craftsman_id = o.craftsman_id
JOIN dwh.d_customer cr ON cr.customer_id = o.customer_id
JOIN dwh.d_product pr ON pr.product_id = o.product_id