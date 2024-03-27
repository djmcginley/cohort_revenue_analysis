-- The following is an example of a customer level revenue retention SQL model

-- GOAL: to understand the value of each customer relative to other users in their registration cohort

-- OPPORTUNITIES: 
  -- 1: Target high quartile retention users with upsells and cross-sells
  -- 2: Target low quartile retention users with discounted win-back offers


-- Starting off by creating a row level base data set with a row for every payment for every customer
WITH customer_retention_base AS (
SELECT 
    u.user_id as customer
    , p.* 
    , SUM(p.payment_amount) OVER(PARTITION BY p.signup_id ORDER BY p.payment_date
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as total_customer_retention_value -- this window function allows us to see a cumulative value of the customer over time as they make payments
    , COUNT(p.payment_amount) OVER(PARTITION BY p.signup_id ORDER BY p.payment_date
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as payment_record_count -- this window function allows us to keep a cumulative count of all the payments a customer has made over time
FROM users u
  LEFT JOIN payments p 
    ON u.signup_id = p.signup_id
ORDER BY p.user_id,p.payment_date
)

-- The final select statement generates a list of all customers and splits them into quartiles based on their relative value and controls for registration cohort (time elapsed since user first signed up)
SELECT 
  distinct(customer) as customer
  , date_trunc('month',registration_at) as reg_month
  , MAX(total_customer_retention_value) as value
  , NTILE(4) OVER(PARTITION BY customer ORDER BY value) as quartile
FROM customer_retention_base
WHERE 1=1 
  and months_since_registration >= 0 
  and registration_at >= '2020-01-01'
GROUP BY 1,2,3
    HAVING MAX(payment_record_count)  -- if a refund is the final record, the max value won't correlate to actual total value; controlling for that here
ORDER BY 1,2,3,4
