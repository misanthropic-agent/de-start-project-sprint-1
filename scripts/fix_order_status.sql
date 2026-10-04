UPDATE TABLE dwh.f_order o
SET o.order_status = 'in-progress'
WHERE o.order_status = 'in progress'