# import json
# import boto3

# # Initialize the SQS client
# sqs_client = boto3.client('sqs')

# # Define the SQS queue URL (replace with your queue's URL)
# SQS_QUEUE_URL = "https://sqs.us-east-1.amazonaws.com/890742567343/image-processing-queue"

# def lambda_handler(event, context):
#     print("Received event:", json.dumps(event, indent=2))

#     # Check for Records in the event
#     records = event.get('Records', [])
#     if not records:
#         return {"statusCode": 400, "body": "No records in event"}

#     for record in records:
#         bucket = record['s3']['bucket']['name']
#         key = record['s3']['object']['key']

#         # Prepare the message body
#         message_body = {
#             "bucket": bucket,
#             "key": key,
#             "event": record
#         }

#         # Send the message to the SQS queue
#         try:
#             response = sqs_client.send_message(
#                 QueueUrl=SQS_QUEUE_URL,
#                 MessageBody=json.dumps(message_body)
#             )
#             print(f"Message sent to SQS: {response['MessageId']}")
#         except Exception as e:
#             print(f"Failed to send message to SQS: {e}")
#             return {"statusCode": 500, "body": str(e)}

#     return {
#         "statusCode": 200,
#         "body": "Messages successfully sent to SQS"
#     }


# import json
# import boto3

# # Initialize the SQS client
# sqs_client = boto3.client('sqs')

# # Define the SQS queue URL
# SQS_QUEUE_URL = "https://sqs.us-east-1.amazonaws.com/890742567343/image-processing-queue"

# def lambda_handler(event, context):
#     # Log the received event for debugging
#     print("Received event:", json.dumps(event, indent=2))

#     # Check for Records in the event
#     records = event.get('Records', [])
#     if not records:
#         print("No records found in the event")
#         return {"statusCode": 400, "body": "No records in event"}

#     # Process each record
#     for record in records:
#         try:
#             # Extract bucket and object details
#             bucket = record['s3']['bucket']['name']
#             key = record['s3']['object']['key']

#             # Prepare the message body
#             message_body = {
#                 "bucket": bucket,
#                 "key": key,
#                 "event": record
#             }

#             # Log the message body for debugging
#             print("Message body:", json.dumps(message_body, indent=2))

#             # Send the message to the SQS queue
#             response = sqs_client.send_message(
#                 QueueUrl=SQS_QUEUE_URL,
#                 MessageBody=json.dumps(message_body)
#             )
#             print(f"Message sent to SQS: {response['MessageId']}")
#         except Exception as e:
#             print(f"Failed to process record: {e}")
#             return {"statusCode": 500, "body": str(e)}

#     return {"statusCode": 200, "body": "Messages successfully sent to SQS"}



import json
import boto3

# Initialize the SQS client
sqs_client = boto3.client('sqs')

# Define the SQS queue URL
SQS_QUEUE_URL = "https://sqs.us-east-1.amazonaws.com/890742567343/image-processing-queue"

def lambda_handler(event, context):
    # Log the received event
    print("Received event:", json.dumps(event, indent=2))

    # Extract details from the EventBridge event
    try:
        bucket_name = event['detail']['bucket']['name']
        object_key = event['detail']['object']['key']
        object_size = event['detail']['object']['size']

        # Prepare the message body
        message_body = {
            "bucket": bucket_name,
            "key": object_key,
            "size": object_size,
            "event": event  # Include full event for reference
        }

        # Log the message body for debugging
        print("Message body:", json.dumps(message_body, indent=2))

        # Send the message to the SQS queue
        response = sqs_client.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps(message_body)
        )
        print(f"Message sent to SQS: {response['MessageId']}")
    except KeyError as e:
        print(f"Missing key in event data: {e}")
        return {"statusCode": 400, "body": f"KeyError: {e}"}
    except Exception as e:
        print(f"Failed to process event: {e}")
        return {"statusCode": 500, "body": str(e)}

    return {"statusCode": 200, "body": "Message successfully sent to SQS"}
