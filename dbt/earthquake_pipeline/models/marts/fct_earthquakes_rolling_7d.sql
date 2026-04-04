-- Calculate a 7-day rolling average of the number of earthquakes, including the current day and previous 6 days
SELECT 
    event_date,
    num_earthquakes,
    ROUND(AVG(num_earthquakes) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS avg_num_earthquakes_rolling_7d
FROM {{ ref('fct_earthquakes_daily') }}