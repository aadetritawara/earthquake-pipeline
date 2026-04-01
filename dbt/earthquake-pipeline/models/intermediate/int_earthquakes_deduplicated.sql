{{
  config(
    materialized = 'incremental',
    unique_key = 'earthquake_id',
    incremental_strategy = 'merge'
  )
}}

WITH raw_data AS (
    SELECT * FROM {{ ref('stg_earthquakes') }}
    {% if is_incremental() %}
    -- Only pull data that arrived in Bronze since the last time this model ran
    WHERE ingested_at > (SELECT max(ingested_at) FROM {{ this }})
    {% endif %}
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY earthquake_id 
            ORDER BY updated_time DESC
        ) AS row_num
    FROM raw_data
    )

select * EXCEPT(row_num)
from deduplicated
where row_num = 1