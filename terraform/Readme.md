# Run Terraform
terraform init
terraform plan
terraform apply

# Authenticate AWS CLI
$env:AWS_ACCESS_KEY_ID = "XXXXXXXXXXXXXXXX"
$env:AWS_SECRET_ACCESS_KEY = "XXXXXXXXXXXXXXXXXXXXXX"

# Authenticate Docker & Push Image
<!-- ECS Task Definition and Service:
In the Terraform script, we defined an ECS task definition that specifies the container image URL (pointing to the ECR repository). This task definition is then associated with an ECS service.

ECS Service Desired Count:
The ECS service configuration in Terraform includes a desired_count parameter (set to 1 in our example). This means ECS will try to maintain one running instance of the task at all times.

Automatic Image Pulling by ECS:
When you create an ECS service and specify a desired count, ECS attempts to pull the specified image and run the task. If the image isn’t available when the ECS service is first created (like before you’ve pushed it to ECR), the ECS service will retry pulling the image from ECR until it’s available. 
 
Therefore, as soon as you push the image to ECR, ECS detects the image is ready and then automatically pulls and starts the container based on the task definition settings.-->
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <accountid>.dkr.ecr.us-east-1.amazonaws.com
docker build -t fastapi-repo-v2 .
docker tag fastapi-repo-v2:latest <accountid>.dkr.ecr.us-east-1.amazonaws.com/fastapi-repo-v2:latest
docker push <accountid>.dkr.ecr.us-east-1.amazonaws.com/fastapi-repo-v2:latest

aws ecr describe-repositories --repository-names fastapi-repo-v2
terraform import module.ecs_service.aws_ecr_repository.fastapi_repo fastapi-repo-v2

269945612333
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 269945612333.dkr.ecr.us-east-1.amazonaws.com
docker build -t fastapi-repo-v2 .
docker tag fastapi-repo-v2:latest 269945612333.dkr.ecr.us-east-1.amazonaws.com/fastapi-repo-v2:latest
docker push 269945612333.dkr.ecr.us-east-1.amazonaws.com/fastapi-repo-v2:latest