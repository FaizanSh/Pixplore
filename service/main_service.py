import boto3
import botocore.config
import logging
import os
from botocore.exceptions import ClientError
print("############################# importing main_service ##############################")
# Fetch environment variables
db_username = os.getenv('DB_USERNAME')
db_password = os.getenv('DB_PASSWORD')
cluster_arn = os.getenv('CLUSTER_ARN')
db_name = os.getenv('DB_NAME')
region = os.getenv('REGION')
secret_arn = os.getenv('SECRET_ARN')
print(f"#######################-{secret_arn}-########################")

if not all([db_username, db_password, cluster_arn, db_name, region]):
    raise Exception("Missing required environment variables for database connection.")


aws_config = botocore.config.Config(
    region_name=os.getenv('REGION'),
    signature_version='v4',
    retries={
        'max_attempts': int(os.getenv('DEFAULT_MAX_CALL_ATTEMPTS') or '1'),
        'mode': 'standard'
    }
)

logger = logging.getLogger()
logger.setLevel(logging.INFO)

secret_name = "pixplore-secret"  # Replace with a meaningful name
secrets_manager_client = boto3.client('secretsmanager', config=aws_config)
rds_client = boto3.client('rds-data', config=aws_config)



def get_or_create_secret():
    """Get the secret if it exists, or create it if it doesn't."""
    try:
        # Check if the secret exists
        response = secrets_manager_client.describe_secret(SecretId=secret_name)
        logger.info(f"Secret already exists: {response['ARN']}")
        return response['ARN']
    except ClientError as e:
        # If the secret doesn't exist, create it
        if e.response["Error"]["Code"] == "ResourceNotFoundException":
            logger.info("Secret not found. Creating a new secret...")
            response = secrets_manager_client.create_secret(
                Name=secret_name,
                Description="Database credentials for Aurora RDS",
                SecretString=f'{{"username":"{db_username}","password":"{db_password}"}}',
                Tags=[{"Key": "Purpose", "Value": "AuroraRDSAccess"}]
            )
            logger.info(f"Secret created successfully: {response['ARN']}")
            return response['ARN']
        else:
            # Re-raise any other exceptions
            logger.error(f"Unexpected error: {e}")
            raise

def execute_statement(sql, sql_parameters=[]):
    try:
        print(f"#######################-{secret_arn}-########################")
        if not secret_arn:
            mew_secret_arn = get_or_create_secret()
        else:
            mew_secret_arn = secret_arn

        response = rds_client.execute_statement(
            database=db_name,
            resourceArn=cluster_arn,
            sql=sql,
            parameters=sql_parameters,
            secretArn=mew_secret_arn
        )
        return response
    except Exception as e:
        logger.error(f"Error executing SQL statement in execute_statement: {e}")
        raise

def batch_execute_statement(sql, sql_parameter_sets):
    try:
        if not secret_arn:
            mew_secret_arn = get_or_create_secret()
        else:
            mew_secret_arn = secret_arn
        response = rds_client.batch_execute_statement(
            database=db_name,
            resourceArn=cluster_arn,
            sql=sql,
            parameterSets=sql_parameter_sets,
            secretArn=secret_arn
        )
        return response
    except Exception as e:
        logger.error(f"Error executing SQL statement batch_execute_statement: {e}")
        raise