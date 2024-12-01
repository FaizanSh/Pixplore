# main.tf

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-unique-faizanullah-lab"
#     key            = "pixplore/terraform/state/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#   }
# }

module "image_metadata_lambda" {
  source          = "./modules/lambda/image-data"
  function_name   = "Image_Metadata_Reader"
  runtime         = "python3.10"
  handler         = "main.handler"
  filename        = "${path.module}/modules/lambda/image-data/imageData.zip"
  source_code_hash = filebase64sha256("${path.module}/modules/lambda/image-data/imageData.zip")
}

module "upload_photo_lambda" {
  source                         = "./modules/lambda/upload-photo"
  function_name                  = "Upload_Photo_Lambda"
  runtime                        = "python3.10"
  handler                        = "main.handler"
  filename                       = "${path.module}/modules/lambda/upload-photo/getSignedUrl.zip"
  source_code_hash               = filebase64sha256("${path.module}/modules/lambda/upload-photo/getSignedUrl.zip")
  images_bucket                  = module.s3_bucket.bucket_name
  default_signedurl_expiry_seconds = "3600"
}

resource "aws_cloudwatch_event_bus" "image_content_bus" {
  name = "ImageContentBus"
}

module "image_analysis_lambda" {
  source                         = "./modules/lambda/image-analyse"
  function_name                  = "Image_Analysis_Lambda"
  runtime                        = "python3.10"
  handler                        = "main.handler"
  filename                       = "${path.module}/modules/lambda/image-analyse/imageAnalysis.zip"
  source_code_hash               = filebase64sha256("${path.module}/modules/lambda/image-analyse/imageAnalysis.zip")
  region                         = "us-east-1"
  images_bucket                  = module.s3_bucket.bucket_name
  event_bus                      = aws_cloudwatch_event_bus.image_content_bus.name
  default_max_call_attempts      = "3"
}

# EventBridge
module "eventbridge" {
  source               = "./modules/eventbridge"
  event_bus_name       = "ImageContentBus"
  event_rule_name      = "Pixplore-ImageRule"
  event_rule_description = "The event from image analyzer to store the data"
  event_pattern        = jsonencode({
    resources = [
      module.image_analysis_lambda.lambda_arn
    ]
  })
  target_lambda_arn    = module.image_metadata_lambda.lambda_arn
  target_lambda_name   = module.image_metadata_lambda.lambda_name

}

module "image_queue_lambda" {
  source                         = "./modules/lambda/image-queue"
  function_name                  = "Image_Queue_Lambda"
  runtime                        = "python3.10"
  handler                        = "main.handler"
  region                         = "us-east-1"
  filename                       = "${path.module}/modules/lambda/image-queue/imageQueue.zip"
  source_code_hash               = filebase64sha256("${path.module}/modules/lambda/image-queue/imageQueue.zip")
  queue_name                     = "Pixplore-SQS"
}

module "s3_bucket" {
  source = "./modules/s3"
  bucket_name = "pixplore-s3-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "pixplore-s3-1"
  }
  versioning = false
}

module "cloudfront" {
  source                  = "./modules/cloudfront"
  s3_bucket_name          = module.s3_bucket.bucket_name
  s3_bucket_domain_name   = module.s3_bucket.bucket_domain_name
  default_root_object     = "index.html"
  default_ttl             = 3600
  max_ttl                 = 86400
  price_class             = "PriceClass_100"
}

module "cognito" {
  source           = "./modules/cognito"
  region           = "us-east-1"
  cognito_callback_url    = "${module.api_gateway.api_endpoint}/prod/landing-page"
  user_pool_domain = "pixplore-user-pool-${data.aws_caller_identity.current.account_id}"
  cognito_logout_url = "https://pixplore-user-pool-${data.aws_caller_identity.current.account_id}.auth.us-east-1.amazoncognito.com/login"
  # cognito_logout_url      = "https://pixplore-user-pool-1.auth.us-east-1.amazoncognito.com/login?client_id=3cvgtrv35uvlu8oft4iauhede1&response_type=code&scope=email+openid+profile&redirect_uri=https%3A%2F%2Fvrq1p5xkr6.execute-api.us-east-1.amazonaws.com%2Fprod%2Flanding-page"
}

module "landing_page_lambda" {
  source          = "./modules/lambda/landing-page"
  function_name   = "Landing_Page_Lambda"
  runtime          = "nodejs18.x" 
  handler         = "main.handler"
  filename        = "${path.module}/modules/lambda/landing-page/landingPage.zip"
  source_code_hash = filebase64sha256("${path.module}/modules/lambda/landing-page/landingPage.zip")
  cognito_client_id = module.cognito.user_pool_client_id
  cognito_client_secret = module.cognito.cognito_client_secret
  cognito_token_url = module.cognito.cognito_token_url
}

module "ecs_service" {
  source          = "./modules/ecs_service"
  region          = "us-east-1"
  cluster_name    = "fastapi-cluster"
  repository_name = "fastapi-repo-v2"
  task_family     = "fastapi-task"
  task_cpu        = "256"
  task_memory     = "512"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  desired_count   = 1
  upload_photo_lambda_target_group_arn = module.upload_photo_lambda.target_group_arn
  landing_page_lambda_target_group_arn = module.landing_page_lambda.target_group_arn
}

module "api_gateway" {
  source = "./modules/api_gateway"
  region = "us-east-1"
  lambda_names = [
    module.landing_page_lambda.lambda_name,
    module.image_metadata_lambda.lambda_name,
    module.upload_photo_lambda.lambda_name,
    module.image_queue_lambda.lambda_name,
    module.image_analysis_lambda.lambda_name,
  ]
  lambda_invoke_arns = [
    module.landing_page_lambda.lambda_invoke_arn,
    module.image_metadata_lambda.lambda_invoke_arn,
    module.upload_photo_lambda.lambda_invoke_arn,
    module.image_queue_lambda.lambda_invoke_arn,
    module.image_analysis_lambda.lambda_invoke_arn,
    ]
  lambda_paths = ["landing-page", "image-data", "upload-photo", "image-queue", "image-analyse"]

  cognito_user_pool_client_id = module.cognito.user_pool_client_id
  cognito_user_pool_issuer    = module.cognito.user_pool_issuer
  cognito_user_pool_arn       = module.cognito.user_pool_arn

  ecs_alb_dns_name = module.ecs_service.alb_dns_name
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  azs                = ["us-east-1a", "us-east-1b"]
  vpc_name           = "fastapi-vpc"
}

# resource "null_resource" "update_lambda_environment" {
#   triggers = {
#     api_url = module.api_gateway.api_endpoint
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       # Fetch existing environment variables
#       EXISTING_ENV=$(aws lambda get-function-configuration \
#         --function-name ${module.landing_page_lambda.lambda_name} \
#         --query "Environment.Variables" \
#         --output json) && \

#       # Merge the new variable with the existing ones
#       UPDATED_ENV=$(echo $EXISTING_ENV | jq '. + {"API_URL": "${module.api_gateway.api_endpoint}"}') && \

#       # Update Lambda with the merged environment variables
#       aws lambda update-function-configuration \
#         --function-name ${module.landing_page_lambda.lambda_name} \
#         --environment "Variables=$UPDATED_ENV"
#     EOT
#   }

#   depends_on = [module.api_gateway]
# }

output "url" {
  value = module.api_gateway.api_endpoint
}
# output cognito URL
# output "cognito_url" {
#   value = module.cognito.cognito_url
# }