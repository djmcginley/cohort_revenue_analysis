-- The following is an example SQL query I would use to monitor new cohort health and WoW top of funnel performance

SELECT 
 date_trunc('week',signup_at) as registration_cohort
 , COUNT(DISTINCT signup_id) as new_registrations
 , COUNT(DISTINCT CASE WHEN DATEDIFF('day',signup_at,payment_at) <= 7 THEN signup_id ELSE null END) as first_7d_new_payers
 , SUM(CASE WHEN days_since_signup >= 0 AND days_since_signup <= 7 THEN payment_amount END) as first_7d_revenue
 , ROUND(revenue::first_7d_revenue / new_registrations,1) as cohort_arpu
 , ROUND(revenue::first_7d_revenue / first_7d_new_payers,1) as cohort_arppu
FROM users u  
  LEFT JOIN payments p
    ON u.signup_id = p.signup_id
WHERE 1=1
  and signup_at >= '2023-01-01'
GROUP BY 1
ORDER BY 1
;
