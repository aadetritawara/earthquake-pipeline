WITH region_data AS (
    SELECT place, 
           event_time,
           -- Extract region from the 'place' column by taking the last part after the comma
           TRIM(element_at(split(place, ','), -1)) AS region
    FROM {{ ref('int_earthquakes_deduplicated') }}
)
SELECT region,
       COUNT(*) AS num_earthquakes
FROM region_data
WHERE event_time >= DATE_SUB(CURRENT_DATE(), 30)
GROUP BY 1