WITH customer_cart_source AS (
    SELECT DISTINCT customer_id, traffic_source
    FROM events
    WHERE event_type = 'add_to_cart'
),
customer_purchase AS (
    SELECT DISTINCT customer_id
    FROM events
    WHERE event_type = 'purchase'
)
SELECT
    traffic_source,
    COUNT(*) AS total_add_to_cart_customer,
    SUM(CASE WHEN customer_id NOT IN (SELECT customer_id FROM customer_purchase) THEN 1 ELSE 0 END) AS total_abandon,
    ROUND(
        SUM(CASE WHEN customer_id NOT IN (SELECT customer_id FROM customer_purchase) THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
    , 2) AS abandonment_rate_pct
FROM customer_cart_source
GROUP BY traffic_source
ORDER BY abandonment_rate_pct DESC;
