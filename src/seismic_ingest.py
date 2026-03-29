import json
import urllib.request 
import boto3
import os
from datetime import datetime, timezone

s3 = boto3.client('s3')

def lambda_handler(event, context):
    try:
        
        bucket_name = os.environ['BUCKET_NAME']

        # Get data from the last hour from USGS
        print("Fetching earthquake data...")
        url = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"
        response = urllib.request.urlopen(url)
        data = json.loads(response.read().decode('utf-8'))

        # Generate filename with timestamp to avoid overwriting previously saved files
        timestamp = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')
        file_name = f"raw_seismic_{timestamp}.json"

        # Upload the JSON data to bucket
        print(f"Uploading {file_name} to {bucket_name}...")
        s3.put_object(
            Bucket=bucket_name,
            Key=file_name,
            Body=json.dumps(data)
        )

        print("Success!")
        return {
            'statusCode': 200,
            'body': f'Successfully uploaded {file_name} to S3'
        }
        
    except Exception as e:
        print(f"Error occurred: {e}")
        raise e