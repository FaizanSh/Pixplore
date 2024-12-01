import boto3
import json

rekognition_client = boto3.client('rekognition')

def lambda_handler(event, context):
    print("Received event:", json.dumps(event, indent=2))

    for record in event['Records']:
        message_body = json.loads(record['body'])
        bucket = message_body['bucket']
        key = message_body['key']

        try:
            response = rekognition_client.detect_labels(
                Image={
                    'S3Object': {
                        'Bucket': bucket,
                        'Name': key
                    }
                },
                MaxLabels=10,
                MinConfidence=75
            )

            print(f"Rekognition response for {key}:", json.dumps(response, indent=2))

        except Exception as e:
            print(f"Failed to process image {key} in bucket {bucket}: {e}")
