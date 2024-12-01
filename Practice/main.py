import boto3
import datetime

def generate_presigned_url(bucket_name, object_key, expiration=3600):
    """
    Generate a presigned URL for uploading a file to S3.
    
    Args:
        bucket_name (str): Name of the S3 bucket.
        object_key (str): The key (path) for the object in the bucket.
        expiration (int): Time in seconds for the presigned URL to remain valid (default: 1 hour).
    
    Returns:
        str: A presigned URL.
    """
    # Create an S3 client
    s3_client = boto3.client('s3')
    
    try:
        # Generate the presigned URL
        response = s3_client.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': bucket_name,
                'Key': object_key,
                'ContentType': 'image/jpeg'
            },
            ExpiresIn=expiration
        )
        return response
    except Exception as e:
        print("Error generating presigned URL:", e)
        return None

# Usage
bucket_name = "pixplore-s3-127214195272"
object_key = "jacket.jpg"
presigned_url = generate_presigned_url(bucket_name, object_key)

if presigned_url:
    print("Presigned URL for upload:", presigned_url)
