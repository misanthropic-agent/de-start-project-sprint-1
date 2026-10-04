WITH
last_load AS ( -- дата последней загрузки витрины
    SELECT COALESCE(MAX(load_dttm), '1900-01-01'::timestamp) AS dttm
    FROM dwh.load_dates_customer_report_datamart
),
delta AS ( -- пары «заказчик + месяц», по которым что-то изменилось в DWH после последней загрузки
    SELECT customer_id, report_period, max_dttm
    FROM (
        SELECT fo.customer_id,
               TO_CHAR(fo.order_created_date, 'yyyy-mm') AS report_period,
               GREATEST(fo.load_dttm, dc.load_dttm, dcs.load_dttm, dp.load_dttm) AS max_dttm
        FROM dwh.f_order fo
            JOIN dwh.d_craftsman dc ON dc.craftsman_id = fo.craftsman_id
            JOIN dwh.d_customer dcs ON dcs.customer_id = fo.customer_id
            JOIN dwh.d_product dp   ON dp.product_id   = fo.product_id
    ) t, last_load ll
    WHERE t.max_dttm > ll.dttm
),
result AS ( -- пересчёт по всем заказам затронутых пар
    SELECT
        fo.customer_id,
        TO_CHAR(fo.order_created_date, 'yyyy-mm') AS report_period,
        SUM(dp.product_price)                                   AS customer_money,
        SUM(dp.product_price) * 0.1                             AS platform_money,
        COUNT(*)                                                AS count_order,
        AVG(dp.product_price)                                   AS avg_price_order,
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY fo.order_completion_date - fo.order_created_date
        ) FILTER (WHERE fo.order_status = 'done')               AS median_time_order_completed,
        MODE() WITHIN GROUP (ORDER BY dp.product_type)          AS top_product_category,
        MODE() WITHIN GROUP (ORDER BY fo.craftsman_id)          AS top_craftsman_id,
        COUNT(*) FILTER (WHERE fo.order_status = 'created')                         AS count_order_created,
        COUNT(*) FILTER (WHERE fo.order_status IN ('in progress', 'in-progress'))   AS count_order_in_progress,
        COUNT(*) FILTER (WHERE fo.order_status = 'delivery')                        AS count_order_delivery,
        COUNT(*) FILTER (WHERE fo.order_status = 'done')                            AS count_order_done,
        COUNT(*) FILTER (WHERE fo.order_status <> 'done')                           AS count_order_not_done
    FROM dwh.f_order fo
        JOIN dwh.d_product dp ON dp.product_id = fo.product_id
    WHERE (fo.customer_id, TO_CHAR(fo.order_created_date, 'yyyy-mm')) IN (SELECT customer_id, report_period FROM delta)
    GROUP BY fo.customer_id, TO_CHAR(fo.order_created_date, 'yyyy-mm')
),
upsert AS ( -- новые записи вставляются, существующие обновляются
    INSERT INTO dwh.customer_report_datamart (
        customer_id, customer_name, customer_address, customer_birthday, customer_email,
        customer_money, platform_money, count_order, avg_price_order, median_time_order_completed,
        top_product_category, top_craftsman_id,
        count_order_created, count_order_in_progress, count_order_delivery,
        count_order_done, count_order_not_done, report_period
    )
    SELECT
        r.customer_id, c.customer_name, c.customer_address, c.customer_birthday, c.customer_email,
        ROUND(r.customer_money, 2), ROUND(r.platform_money, 2), r.count_order, ROUND(r.avg_price_order, 2),
        ROUND(r.median_time_order_completed::numeric, 1),
        r.top_product_category, r.top_craftsman_id,
        r.count_order_created, r.count_order_in_progress, r.count_order_delivery,
        r.count_order_done, r.count_order_not_done, r.report_period
    FROM result r
        JOIN dwh.d_customer c ON c.customer_id = r.customer_id
    ON CONFLICT (customer_id, report_period) DO UPDATE SET
        customer_name = EXCLUDED.customer_name,
        customer_address = EXCLUDED.customer_address,
        customer_birthday = EXCLUDED.customer_birthday,
        customer_email = EXCLUDED.customer_email,
        customer_money = EXCLUDED.customer_money,
        platform_money = EXCLUDED.platform_money,
        count_order = EXCLUDED.count_order,
        avg_price_order = EXCLUDED.avg_price_order,
        median_time_order_completed = EXCLUDED.median_time_order_completed,
        top_product_category = EXCLUDED.top_product_category,
        top_craftsman_id = EXCLUDED.top_craftsman_id,
        count_order_created = EXCLUDED.count_order_created,
        count_order_in_progress = EXCLUDED.count_order_in_progress,
        count_order_delivery = EXCLUDED.count_order_delivery,
        count_order_done = EXCLUDED.count_order_done,
        count_order_not_done = EXCLUDED.count_order_not_done
)
INSERT INTO dwh.load_dates_customer_report_datamart (load_dttm) -- фиксируем дату загрузки, только если в дельте что-то было
SELECT MAX(max_dttm) FROM delta HAVING COUNT(*) > 0;