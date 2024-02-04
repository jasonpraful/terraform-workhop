# The following infrastructure will be created:
# Cloudfront distribution -> S3 bucket -> S3 bucket policy 
# Cloudfront Distribution -> `/api/*` -> API Gateway -> Lambda -> DynamoDB

variable "aws_region" {
  description = "AWS region to deploy to"
  default     = "eu-west-1"
}

variable "frontend_s3_bucket_name" {
  description = "Name of the S3 bucket to create for the frontend"
  default     = "jasonvf-frontend-bucket"
}

variable "cloudfront_ui_cache_policy_id" {
  description = "ID of the Cloudfront cache policy to use for the UI"
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "cloudfront_api_cache_policy_id" {
  description = "ID of the Cloudfront origin request policy to use for the API"
  default     = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}

variable "cloudfront_redirect_error_codes" {
  type        = set(number)
  description = "HTTP status codes to redirect to index.html"
  default     = [403, 404]
}


variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to create"
  default     = "terraform-workshop-vf-dynamodb-table"
}


variable "lambda_function_name" {
  description = "Name of the Lambda function to create"
  default     = "terraform-workshop-vf-lambda-function"
}

variable "lambda_iam_role_name" {
  description = "Name of the IAM role to create for the Lambda function"
  default     = "terraform-workshop-vf-lambda-role"
}
