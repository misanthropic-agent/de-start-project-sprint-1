# Интеграция нового источника в DWH и витрина по заказчикам

## Файлы


`tmp_ext4d.sql` - Временная таблица  
`tmp_ext_src`: заказы, мастера и товары из `external_source.  craft_products_orders` вместе с заказчиками из `external_source.  customers`  
`merge_d_craftsman.sql`   Загрузка измерения мастеров `dwh.d_craftsman`   
`merge_d_customer.sql`   Загрузка измерения заказчиков `dwh.d_customer`   
`merge_d_product.sql`   Загрузка измерения товаров `dwh.d_product`   
`tmp_ext4fact.sql`   Временная таблица `tmp_src_f`: заказы с идентификаторами из измерений DWH   
`merge_f.sql`   Загрузка таблицы фактов `dwh.f_order`    
`fix_order_status.sql`   Необязательное исправление статуса `in progress` → `in-progress`   
`ddl_mart.sql`   DDL витрины `dwh.customer_report_datamart` и таблицы загрузок `dwh.load_dates_customer_report_datamart`    
`incremental_update.sql`   Инкрементальное обновление витрины  

## Запуск
1. Загрузка источника в DWH:
```
    tmp_ext4d.sql
    merge_d_craftsman.sql
    merge_d_customer.sql
    merge_d_product.sql
    tmp_ext4fact.sql
    merge_f.sql
```
2. Создание отчета:
```
    ddl_mart.sql
    incremental_update.sql
```


## Статус in[-, ]progress

В источнике и в других витринах статус может записываться как `in progress` или `in-progress`. Витрина считает оба написания. Если нужно привести данные к одному виду:

1. Выполнить `fix_order_status.sql`.
2. Чтобы следующая загрузка не вернула старое значение, нормализовать статус в `tmp_ext4fact.sql`: `REPLACE(src.order_status, 'in progress', 'in-progress') AS order_status`.

Повторный запуск `incremental_update.sql` без новых данных не должен менять витрину и добавлять записи в таблицу загрузок.