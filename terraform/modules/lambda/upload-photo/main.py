import json
import boto3
import logging
import os
import time
import hashlib

from botocore.exceptions import ClientError
# Set up the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)
images_bucket = os.environ['IMAGES_BUCKET']
print("images_bucket: ", images_bucket)
default_signedurl_expiry_seconds = os.environ['DEFAULT_SIGNEDURL_EXPIRY_SECONDS']

# Creates a pre-signed URL for image upload to S3.
logger.info("Lambda function has started")
def handler(event, context):
    uniquehash = hashlib.sha1("{}".format(time.time_ns()).encode('utf-8')).hexdigest()
    result = create_presigned_post(images_bucket, "new/{}/{}".format(uniquehash[:2],uniquehash))

    if not result:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json; charset=UTF-8',
                'Access-Control-Allow-Origin': '*',  # Allow all origins
                'Access-Control-Allow-Methods': 'GET, POST',  # Allowed methods
                'Access-Control-Allow-Headers': 'Authorization, Content-Type',  # Allowed headers
            },
            'body': json.dumps({'error': 'Could not generate pre-signed URL'})
        }

    # Return the pre-signed URL response with CORS headers
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json; charset=UTF-8',
            'Access-Control-Allow-Origin': '*',  # Allow all origins
            'Access-Control-Allow-Methods': 'GET, POST',  # Allowed methods
            'Access-Control-Allow-Headers': 'Authorization, Content-Type',  # Allowed headers
        },
        'body': json.dumps(result)
    }

def create_presigned_post(bucket_name, object_name, fields=None, conditions=None, expiration=default_signedurl_expiry_seconds):
    s3_client = boto3.client('s3')

    try:
        response = s3_client.generate_presigned_post(bucket_name,
            object_name,
            Fields=fields,
            Conditions=conditions,
            ExpiresIn=int(expiration)
        )
        logger.info(f"presigned post response : {response}")
    except ClientError as e:
        logging.error(e)
        return None

    return response