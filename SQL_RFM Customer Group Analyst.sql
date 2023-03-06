--RFM analyst
WITH data_rfm AS ( --Filter data only IN 2016
SELECT 
    account_id,
    MAX(occurred_at) AS last_active_date,
    ('2017-01-01' - MAX(occurred_at::DATE)) AS recency,
    COUNT(DISTINCT id) AS frequency,
    SUM(total_amt_usd) AS monetary
FROM demo.orders
WHERE occurred_at >= '2016-01-01 00:00:00'
    AND occurred_at < '2017-01-01 00:00:00'
GROUP BY account_id
) 
,data_percent_rank AS (
SELECT *,
    PERCENT_RANK() OVER (ORDER BY frequency) as frequency_PERCENT_RANK,
    PERCENT_RANK() OVER (ORDER BY monetary) as monetary_PERCENT_RANK
FROM data_rfm
)
SELECT *,
    CASE 
      WHEN recency BETWEEN 0 AND 15 THEN 3
      WHEN recency BETWEEN 15 AND 30 THEN 2
      WHEN recency > 30 THEN 1
      ELSE 0
      END
      AS recency_rank,
    CASE 
      WHEN frequency_PERCENT_RANK BETWEEN 0.8 AND 1 THEN 3
      WHEN frequency_PERCENT_RANK BETWEEN 0.5 AND 0.8 THEN 2
      WHEN frequency_PERCENT_RANK BETWEEN 0 AND 0.5 THEN 1
      ELSE 0
      END
      AS frequency_rank,
    CASE 
      WHEN monetary_PERCENT_RANK BETWEEN 0.8 AND 1 THEN 3
      WHEN monetary_PERCENT_RANK BETWEEN 0.5 AND 0.8 THEN 2
      WHEN monetary_PERCENT_RANK BETWEEN 0 AND 0.5 THEN 1
      ELSE 0
      END
      AS monetary_rank
FROM data_percent_rank
ORDER BY recency_rank DESC,frequency_rank DESC,monetary_rank DESC
