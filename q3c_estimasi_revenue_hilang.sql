WITH avg_transaction_value AS (
    SELECT AVG(gross_revenue) AS avg_value
    FROM transactions
    WHERE refund_flag = 0
),
customer_cart AS (
    SELECT DISTINCT customer_id FROM events WHERE event_type = 'add_to_cart'
),
customer_purchase AS (
    SELECT DISTINCT customer_id FROM events WHERE event_type = 'purchase'
),
abandoned_customers AS (
    SELECT customer_id FROM customer_cart
    WHERE customer_id NOT IN (SELECT customer_id FROM customer_purchase)
)
SELECT
    COUNT(*) AS jumlah_customer_abandon,
    ROUND((SELECT avg_value FROM avg_transaction_value), 2) AS rata_rata_nilai_transaksi,
    ROUND(COUNT(*) * (SELECT avg_value FROM avg_transaction_value), 2) AS estimasi_potensi_revenue_hilang
FROM abandoned_customers;
