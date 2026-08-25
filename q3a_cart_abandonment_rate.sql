WITH customer_cart AS (
    SELECT DISTINCT customer_id
    FROM events
    WHERE event_type = 'add_to_cart'
),
customer_purchase AS (
    SELECT DISTINCT customer_id
    FROM events
    WHERE event_type = 'purchase'
)
SELECT
    COUNT(*) AS total_customer_add_to_cart,
    SUM(CASE WHEN cc.customer_id NOT IN (SELECT customer_id FROM customer_purchase) THEN 1 ELSE 0 END) AS total_customer_abandon,
    ROUND(
        SUM(CASE WHEN cc.customer_id NOT IN (SELECT customer_id FROM customer_purchase) THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
    , 2) AS cart_abandonment_rate_pct
FROM customer_cart cc;
