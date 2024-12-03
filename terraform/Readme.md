**Runbook Instructions**

**Prerequisites**

-   **AWS CLI** installed and configured

-   **Docker** installed

-   **Terraform** installed

-   Access to an **AWS account** with appropriate permissions

**Running Terraform**

1.  **Initialize Terraform:**

`terraform init`

1.  **Plan the Terraform deployment:**

`terraform plan`

1.  **Apply the Terraform configuration:**

`terraform apply`

**AWS CLI Authentication (If Your CLI Doesn\'t Work)**

Set your AWS credentials in your environment:

**For Windows PowerShell:**

powershell

`$env:AWS_ACCESS_KEY_ID = "YOUR_ACCESS_KEY_ID"`

`$env:AWS_SECRET_ACCESS_KEY = "YOUR_SECRET_ACCESS_KEY"`

**For Linux/macOS Terminal:**

`export AWS_ACCESS_KEY_ID=\"YOUR_ACCESS_KEY_ID\"`

`export AWS_SECRET_ACCESS_KEY=\"YOUR_SECRET_ACCESS_KEY"`

**Authenticate Docker with AWS ECR and Push Image**

To authenticate Docker with your AWS Elastic Container Registry (ECR)
and push your Docker image, follow these steps:

**Notes**

-   In the Terraform script, an ECS task definition is defined that
    specifies the container image URL (pointing to the ECR repository).
    This task definition is associated with an ECS service.

-   The ECS service configuration includes a desired_count parameter
    (set to 1), meaning ECS will try to maintain one running instance of
    the task at all times.

-   When the ECS service is created and specifies a desired count, ECS
    attempts to pull the specified image and run the task. If the image
    isn't available when the ECS service is first created (like before
    you\'ve pushed it to ECR), the ECS service will retry pulling the
    image from ECR until it's available.

-   Therefore, as soon as you push the image to ECR, ECS detects the
    image is ready and then automatically pulls and starts the container
    based on the task definition settings.

**Steps**

1.  **Authenticate Docker to your AWS ECR registry:**

`aws ecr get-login-password \--region us-east-1 \| docker login
\--username AWS \--password-stdin
\<AWS_ACCOUNT_ID\>.dkr.ecr.us-east-1.amazonaws.com`

1.  **Prepare Environment Variables:**

    -   Before building the Docker image, use the sample .env file.

    -   Update all the required variables.

    -   Save it as .env.

2.  **Build the Docker image:**

`docker build -t fastapi-repo-v2 .`

1.  **Tag the Docker image:**

`docker tag fastapi-repo-v2:latest
\<AWS_ACCOUNT_ID\>.dkr.ecr.us-east-1.amazonaws.com/fastapi-repo-v2:latest`

5.  **Push the Docker image to ECR:**

`docker push
\<AWS_ACCOUNT_ID\>.dkr.ecr.us-east-1.amazonaws.com/fastapi-repo-v2:latest`

**Debugging**

If the ECS task doesn\'t deploy automatically, force a new deployment:

`aws ecs update-service \--cluster fastapi-cluster \--service
fastapi-service \--force-new-deployment`

\<!\-- Additional commands that might be helpful: \`\`\`bash aws ecr
describe-repositories \--repository-names fastapi-repo-v2 \`\`\`
\`\`\`bash terraform import
module.ecs_service.aws_ecr_repository.fastapi_repo fastapi-repo-v2
\`\`\` \--\>

**Manual Changes**

**CloudFront**

-   **Enable Behavior Settings:**

    -   Configure CloudFront behavior to change the Content-Type header
        for every file responded from the new folder.

**Database (DB)**

-   **Spin Up Aurora PostgreSQL:**

    -   Launch an Aurora PostgreSQL instance with Secrets Manager
        enabled and Data API updated.

**Lambda Functions**

1.  **Update Rekognition Lambda:**

    -   Add permissions for S3, Secrets Manager, and RDS.

    -   Update environment variables with the correct API Gateway DB
        links and Secrets Manager ARN.

2.  **Update Landing Lambda:**

    -   Add the CloudFront link in the environment variable.

    -   Update the Search Link and Redirect Link for the latest API
        Gateway links.

**ECS**

-   **Enable Auto Scaling:**

    -   Enable Auto Scaling for the service in the fastapi-cluster.

-   **Define Target Policy:**

    -   Define the target scaling policy based on your application\'s
        requirements.

-   **Set ECS Task Limits:**

    -   Adjust the required task limits as per the Auto Scaling policy.
