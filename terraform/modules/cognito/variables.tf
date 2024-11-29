variable "region" {
    description = "The AWS region to deploy the Cognito resources"
    type        = string
    default     = "us-east-1"
}

variable "user_pool_name" {
    description = "The name of the Cognito user pool"
    type        = string
    default     = "pixplore-user-pool"
}

variable "user_pool_domain" {
    description = "The domain of the Cognito user pool"
    type        = string
    # default     = "pixplore-user-pool-3"
}

variable "user_pool_client_name" {
    description = "The name of the Cognito user pool client"
    type        = string
    default     = "pixplore_app_client"
}

variable "cognito_callback_url" {
    description = "The URL to redirect to after login"
    type        = string
}

variable "cognito_logout_url" {
    description = "The URL to redirect to after logout"
    type        = string
}