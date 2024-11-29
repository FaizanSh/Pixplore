# main.tf

provider "aws" {
  region = "us-east-1"
}

module "landing_page_lambda" {
  source          = "./modules/lambda/landing-page"
  function_name   = "Landing_Page"
  runtime         = "python3.10"
  handler         = "main.handler"
  filename        = "${path.module}/modules/lambda/landing-page/landingPage.zip"
  source_code_hash = filebase64sha256("${path.module}/modules/lambda/landing-page/landingPage.zip")
}

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
  images_bucket                  = "pixplore-s3"
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
  images_bucket                  = "pixplore-s3"
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
  bucket_name = "pixplore-s3"
  tags = {
    Name = "pixplore-s3"
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
  # lambda_paths = ["landing-page", "image-data", "upload-photo", "image-queue"]
}

module "ecs_service" {
  source          = "./modules/ecs_service"
  region          = "us-east-1"
  cluster_name    = "fastapi-cluster"
  repository_name = "fastapi-repo-v2"
  task_family     = "fastapi-task"
  task_cpu        = "256"
  task_memory     = "512"
  vpc_id          = "vpc-0eb6c32c3c0c8c507"
  subnet_ids      = ["subnet-0bfd390eabc57e9ef", "subnet-04bfb1b82a4ba8608"]
  desired_count   = 1
  upload_photo_lambda_target_group_arn = module.upload_photo_lambda.target_group_arn
  landing_page_lambda_target_group_arn = module.landing_page_lambda.target_group_arn
}

output "api_gateway_urls" {
  value = module.api_gateway.api_gateway_urls
}