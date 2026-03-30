SELECT DATE(event_time) AS event_date,
       COUNT(earthquake_id) AS num_earthquakes,
       AVG(magnitude) AS avg_magnitude,
       MAX(magnitude) AS max_magnitude,
       MEDIAN(magnitude) AS median_magnitude
FROM {{ ref('int_earthquakes_deduplicated') }}
GROUP BY 1