SELECT 
    id AS earthquake_id,
    coordinates[0] AS longitude,
    coordinates[1] AS latitude,
    coordinates[2] AS depth,
    alert AS alert_color,
    cdi,
    felt AS num_felt_reports,
    mag AS magnitude,
    magType AS magnitude_algorithm,
    mmi,
    place,
    sig AS significance,
    status AS review_status,
    CAST(tsunami AS INT) AS tsunami,
    url AS event_url,
    timestamp_millis(time) AS event_time,
    timestamp_millis(updated) AS updated_time,
    ingested_at,
    source_file AS source_file_name
    
FROM {{ source('usgs_raw', 'bronze_earthquakes') }}