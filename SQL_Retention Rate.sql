WITH data AS ( --Filter data only IN 2016
SELECT *
FROM demo.orders
WHERE occurred_at >= '2016-01-01 00:00:00'
    AND occurred_at < '2017-01-01 00:00:00'
)

, cus_first_month AS ( --The first month every customer purchase
SELECT account_id,
      date_trunc('month',MIN(occurred_at)) as first_month
FROM data
GROUP BY account_id
)

, cus_new_number AS ( --Count new cus
SELECT first_month,
      COUNT(account_id) as new_cus
FROM cus_first_month
GROUP BY first_month
)

, cus_active_month AS (
SELECT account_id,
      date_trunc('month', occurred_at) AS active_month
FROM data
GROUP BY 1,2
ORDER BY 1,2
)

, cus_active_number AS ( --Count Active cus each month
SELECT active_month,
      COUNT(DISTINCT account_id) as active_cus
FROM cus_active_month
GROUP BY active_month
)

, cus_retention_number AS( --Want to see new and retention cus , calculate retention rate
SELECT f.first_month,
      a.active_month,
      count(a.account_id) as cus_rentention
FROM cus_first_month as f
LEFT JOIN cus_active_month as a
ON f.account_id = a.account_id
GROUP BY f.first_month,
         a.active_month
ORDER BY 1,2
)
SELECT r.first_month,
      r.active_month,
      n.new_cus,
      r.cus_rentention,
      (r.cus_rentention:: NUMERIC/n.new_cus) AS retention_rate,
      (EXTRACT(MONTH FROM r.active_month::DATE)-EXTRACT(MONTH FROM r.first_month::DATE)) AS retention_month_num
FROM cus_new_number n
LEFT JOIN cus_retention_number r
ON n.first_month = r.first_month
ORDER BY 1,2
