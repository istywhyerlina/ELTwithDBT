INSERT INTO stg.order_payments 
    (order_id, payment_sequential, payment_type,payment_installments,payment_value) 

SELECT
order_id, payment_sequential, payment_type,payment_installments,payment_value
FROM
    olist.order_payments
