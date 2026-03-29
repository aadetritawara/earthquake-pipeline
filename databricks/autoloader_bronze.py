from pyspark.sql.functions import col, explode, current_timestamp, input_file_name

S3_PATH = "s3://earthquake-pipeline-project-03-2026/"
CHECKPOINT_PATH = "/Volumes/main/default/earthquake_pipeline_storage/checkpoints/bronze"
SCHEMA_PATH     = "/Volumes/main/default/earthquake_pipeline_storage/schemas/bronze"
BRONZE_TABLE = "main.default.bronze_earthquakes"

(
    spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "json")
        .option("cloudFiles.schemaLocation", SCHEMA_PATH)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(S3_PATH)
        .withColumn("feature", explode(col("features")))
        .select(
            col("feature.id").alias("id"),
            col("feature.properties.*"),
            col("feature.geometry.coordinates").alias("coordinates"),
            current_timestamp().alias("ingested_at"),
            input_file_name().alias("source_file")
        )
        .writeStream
        .format("delta")
        .option("checkpointLocation", CHECKPOINT_PATH)
        .option("mergeSchema", "true")
        .trigger(availableNow=True)   
        .toTable(BRONZE_TABLE)
)