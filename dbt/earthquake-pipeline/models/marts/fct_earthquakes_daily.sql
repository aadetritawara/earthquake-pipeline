WITH depth_buckets AS (
    SELECT *, 
            CASE 
                WHEN depth < 70 THEN "Shallow"
                WHEN depth < 300 THEN "Intermediate"
                WHEN depth >= 300 THEN "Deep"
                ELSE "Unknown"
            END AS depth_category
    FROM {{ ref('int_earthquakes_deduplicated') }}
)

SELECT DATE(event_time) AS event_date,
       COUNT(earthquake_id) AS num_earthquakes,
       COUNT(CASE WHEN depth_category = 'Shallow' THEN 1 END) AS shallow_depth_count,
       COUNT(CASE WHEN depth_category = 'Intermediate' THEN 1 END) AS intermediate_depth_count,
       COUNT(CASE WHEN depth_category = 'Deep' THEN 1 END) AS deep_depth_count,
       COUNT(CASE WHEN depth_category = 'Unknown' THEN 1 END) AS unknown_depth_count,
       ROUND(AVG(magnitude), 2) AS avg_magnitude,
       MAX(magnitude) AS max_magnitude,
       ROUND(MEDIAN(magnitude), 2) AS median_magnitude,
       COUNT(DISTINCT place) AS num_unique_locations,
       SUM(tsunami) AS num_tsunamis_warnings
FROM depth_buckets
GROUP BY 1
