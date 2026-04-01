# Earthquake Pipeline

A serverless ETL pipeline implementing a Medallion Architecture (Bronze/Silver/Gold) for USGS seismic data, with a Streamlit dashboard for real-time visualization.

## Pipeline Architecture Overview

![Data pipeline diagram showing earthquake data flow from bronze source through silver staging to gold layers. Starting with bronze_earthquakes (SRC) connecting to stg_earthquakes (MDL), then int_earthquakes_deduplicated (MDL), branching to fct_earthquakes_daily (MDL) which feeds into two final gold tables: fct_earthquakes_by_region_30d and fct_earthquakes_rolling_7d. All connections shown with directional arrows on dark background.](<Pasted Graphic 8.png>)
This project follows the Medallion architecture using dbt to transform raw earthquake data into analytics ready models:

**Bronze (Databricks Unity Catalog Table)**  
Raw earthquake data is ingested from the USGS API into S3 as JSON files and processed using Databricks Auto Loader. The data is flattened and stored in a structured bronze table for downstream processing.

**Staging (View)**  
Performs initial cleaning and standardization, including type casting, timestamp normalization, and column selection and renaming to create a consistent schema.

**Intermediate (Incremental Model)**  
Deduplicates earthquake events using unique identifiers. Implemented as an incremental model to efficiently handle late arriving or updated records without reprocessing the full dataset.

**Fact Tables (Tables)**  
Built for analytical use in the final Streamlit dashboard:
- **Daily metrics**: earthquake counts, magnitude statistics, depth distribution, and tsunami indicators  
- **Rolling 7-day trends**: smoothed earthquake activity to highlight trends over time  
- **Regional aggregation (30 days)**: identifies the most active geographic regions  

These models power a Streamlit dashboard that updates every 15 minutes and visualizes earthquake activity, trends, and geographic patterns.