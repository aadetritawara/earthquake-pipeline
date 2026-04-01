WITH buckets AS (
    SELECT 
        *, 
        CASE 
            WHEN depth < 70 THEN "Shallow"
            WHEN depth < 300 THEN "Intermediate"
            WHEN depth >= 300 THEN "Deep"
            ELSE "Unknown"
        END AS depth_category,
        CASE 
            WHEN magnitude < 3 THEN 'Minor (<3)'
            WHEN magnitude < 5 THEN 'Light (3-5)'
            WHEN magnitude < 7 THEN 'Moderate (5-7)'
            WHEN magnitude >= 7 THEN 'Major (7+)'
            ELSE 'Unknown'
        END AS magnitude_category
    FROM {{ ref('int_earthquakes_deduplicated') }}
)

SELECT 
    DATE(event_time) AS event_date,
    COUNT(earthquake_id) AS num_earthquakes,
    COUNT(CASE WHEN depth_category = 'Shallow' THEN 1 END) AS shallow_depth_count,
    COUNT(CASE WHEN depth_category = 'Intermediate' THEN 1 END) AS intermediate_depth_count,
    COUNT(CASE WHEN depth_category = 'Deep' THEN 1 END) AS deep_depth_count,
    COUNT(CASE WHEN depth_category = 'Unknown' THEN 1 END) AS unknown_depth_count,
    COUNT(CASE WHEN magnitude_category = 'Minor (<3)' THEN 1 END) AS minor_magnitude_count,
    COUNT(CASE WHEN magnitude_category = 'Light (3-5)' THEN 1 END) AS light_magnitude_count,
    COUNT(CASE WHEN magnitude_category = 'Moderate (5-7)' THEN 1 END) AS moderate_magnitude_count,
    COUNT(CASE WHEN magnitude_category = 'Major (7+)' THEN 1 END) AS major_magnitude_count,
    COUNT(CASE WHEN magnitude_category = 'Unknown' THEN 1 END) AS unknown_magnitude_count,
    ROUND(AVG(magnitude), 2) AS avg_magnitude,
    MAX(magnitude) AS max_magnitude,
    COALESCE(SUM(tsunami), 0) AS num_tsunami_warnings
FROM buckets
GROUP BY 1
