import boto3
import json
from helper import batch_execute_statement, execute_statement

rekognition_client = boto3.client('rekognition')

def create_schema():

    # do migration
    create_table_and_index = """
        CREATE TABLE IF NOT EXISTS tags
        (image_id VARCHAR(40) NOT NULL, label VARCHAR(64) NOT NULL,
        PRIMARY KEY (image_id, label),
        INDEX (image_id, label));
    """

    try:
        execute_statement(create_table_and_index)
        response = execute_statement("SHOW TABLES;")
        print(f'List of tables: {response}')
    except Exception as e:
        print(f'Something went wrong while creating table: {e}')
        raise e

    return True


def insert_new_image(image_id, labels):

    statement = 'INSERT INTO tags (image_id, label) values (:image_id, :label)'
    params_sets = []

    for l in labels:
        params_sets.append([
                {'name':'image_id', 'value':{'stringValue': image_id}},
                {'name':'label', 'value':{'stringValue': l}}
        ])

    response = batch_execute_statement(statement, params_sets)

    print(f'Number of records updated: {len(response["updateResults"])}')

    return response

def lambda_handler(event, context):
    # create_schema()
    print("Received event:", json.dumps(event, indent=2))

    for record in event['Records']:
        message_body = json.loads(record['body'])
        bucket = message_body['bucket']
        key = message_body['key']

        try:
            detected_labels = rekognition_client.detect_labels(
            Image={'S3Object': {'Bucket': bucket, 'Name': key}},
            MaxLabels=20,
            MinConfidence=85)

            detected_unsafe_contents = rekognition_client.detect_moderation_labels(
                Image={'S3Object': {'Bucket': bucket, 'Name': key}})

            object_labels = []

            for l in detected_labels['Labels']:
                object_labels.append(l['Name'].lower()) # add objects in image

            for l in detected_unsafe_contents['ModerationLabels']:
                if ('offensive' not in object_labels): object_labels.append("offensive") #label image as offensive
                object_labels.append(l['Name'].lower())

            image_id = "https://ds9pv60isbe1e.cloudfront.net/" + key
            labels = object_labels
            response = insert_new_image(image_id, object_labels)
            return response
            
        except Exception as e:
            print(f"Failed to process image {key} in bucket {bucket}: {e}")
