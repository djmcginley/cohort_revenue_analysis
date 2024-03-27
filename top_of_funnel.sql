-- The following is an example of how I'd create a dataset to monitor key marketing metrics across each network, platform, and campaign combination

SELECT 
  date_trunc('week',spend_date) as week
  , network_name  
  , platform
  , campaign_name
  , ROUND(SUM(spend),0) as media_spend
  , COUNT(DISTINCT i.install_id) AS installs
  , media_spend::float / installs AS cost_per_install
  , COUNT(DISTINCT u.user_id) AS registrations
  , media_spend::float / registrations AS cost_per_reg
  , COUNT(DISTINCT CASE WHEN DATEDIFF(day,i.install_date,u.signup_date) <= 7 THEN u.user_id END) AS registrations_d7
  , COUNT(DISTINCT (CASE WHEN p.total_payments_7d > 0 THEN p.payment_user_id ELSE NULL END)) AS payers_within_7d
  , COUNT(DISTINCT (CASE WHEN p.subscription_payments_7d > 0 THEN p.payment_user_id ELSE NULL END)) AS subscriptions_within_7d
  , media_spend::float / subscriptions_within_7d AS cost_per_subscription
  , SUM(p.total_payments_lifetime) AS total_payments
  , total_payments::float / media_spend AS current_roas
  , SUM(p.subscription_payments_lifetime) AS subscription_payments_lifetime
  , SUM(p.credit_payments_lifetime) AS credit_payments_lifetime
  , SUM(f.six_month_forecasted_payments) AS six_month_forecasted_payments
  , SUM(f.one_year_forecasted_payments) AS one_year_forecasted_payments
  , SUM(f.eighteen_month_forecasted_payments) AS eighteen_month_forecasted_payments
  , SUM(f.two_year_forecasted_payments) AS two_year_forecasted_payments
  , two_year_forecasted_payments::float / media_spend AS predicted_two_year_roas
FROM installs_data i
  LEFT JOIN user_data u ON i.install_id = u.user_id
  LEFT JOIN payment_data p ON u.user_id = p.payment_user_id
  LEFT JOIN forecast_data f ON r.revenue_user_id = u.user_id
WHERE 1=1
  AND spend_date >= '2022-01-01'
GROUP BY 1,2,3,4,5
ORDER BY 1,2,3,4,5
;
