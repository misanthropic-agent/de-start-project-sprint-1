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

CREATE TABLE dwh.customer_report_datamart (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    customer_id BIGINT NOT NULL,
    customer_name VARCHAR NOT NULL,
    customer_address VARCHAR NOT NULL,
    customer_birthday DATE NOT NULL,
    customer_email VARCHAR NOT NULL,
    customer_money NUMERIC(15,2) NOT NULL,
    platform_money NUMERIC(15,2) NOT NULL,
    count_order BIGINT NOT NULL,
    avg_price_order NUMERIC(10,2) NOT NULL,
    median_time_order_completed NUMERIC(10,1),
    top_product_category VARCHAR NOT NULL,
    top_craftsman_id BIGINT NOT NULL,
    count_order_created BIGINT NOT NULL,
    count_order_in_progress BIGINT NOT NULL,
    count_order_delivery BIGINT NOT NULL,
    count_order_done BIGINT NOT NULL,
    count_order_not_done BIGINT NOT NULL,
    report_period VARCHAR NOT NULL,
    CONSTRAINT customer_report_datamart_pk PRIMARY KEY (id),
    CONSTRAINT customer_report_datamart_uq UNIQUE (customer_id, report_period)
);

DROP TABLE IF EXISTS dwh.load_dates_customer_report_datamart;

CREATE TABLE dwh.load_dates_customer_report_datamart (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    load_dttm TIMESTAMP NOT NULL,
    CONSTRAINT load_dates_customer_report_datamart_pk PRIMARY KEY (id)
);