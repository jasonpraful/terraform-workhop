######################
# Frontend S3 bucket #
######################
resource "aws_s3_bucket" "frontend_bucket" {
  bucket        = var.frontend_s3_bucket_name
  force_destroy = true


  tags = {
    Name        = var.frontend_s3_bucket_name
    Environment = local.environment
    Project     = local.project_name
  }

  lifecycle {
    prevent_destroy = false
  }
}
resource "aws_s3_bucket_website_configuration" "frontend_bucket_website_configuration" {
  bucket = aws_s3_bucket.frontend_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }

}


resource "aws_s3_bucket_ownership_controls" "frontend_bucket_ownership_controls" {
  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "frontend_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.frontend_bucket_ownership_controls]
  bucket     = aws_s3_bucket.frontend_bucket.id
  acl        = "private"

}

####################################################
# IAM  to allow Cloudfront to access the S3 bucket #
####################################################

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}


###########################
# Cloudfront Distribution #
###########################

resource "aws_cloudfront_origin_access_identity" "cf_s3_origin_access_identity" {
  comment = "Allow CloudFront to reach the S3 bucket"
}


resource "aws_cloudfront_distribution" "cf_distribution" {
  depends_on = [aws_s3_bucket.frontend_bucket]
  enabled    = true


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.frontend_bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_s3_origin_access_identity.cloudfront_access_identity_path
    }
  }
  origin {
    domain_name = "${aws_api_gateway_rest_api.messages_api.id}.execute-api.${var.aws_region}.amazonaws.com"
    origin_id   = "messages_api"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_root_object = "index.html"
  is_ipv6_enabled     = true

  price_class = "PriceClass_100"

  default_cache_behavior {
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["HEAD", "GET"]
    cache_policy_id        = var.cloudfront_ui_cache_policy_id
    target_origin_id       = aws_s3_bucket.frontend_bucket.id
    viewer_protocol_policy = "redirect-to-https"
  }

  dynamic "custom_error_response" {
    for_each = var.cloudfront_redirect_error_codes
    content {
      error_caching_min_ttl = 200
      error_code            = custom_error_response.value
      response_code         = custom_error_response.value
      response_page_path    = "/index.html"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  ordered_cache_behavior {
    allowed_methods          = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods           = ["HEAD", "GET"]
    cache_policy_id          = var.cloudfront_api_cache_policy_id
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    target_origin_id         = "messages_api"
    viewer_protocol_policy   = "redirect-to-https"
    path_pattern             = "/api/*"
  }

  tags = {
    Name        = "Workshop Cloudfront Distribution"
    Environment = local.environment
    Project     = local.project_name
  }
}



############
# DynamoDB #
############

resource "aws_dynamodb_table" "messages_table" {
  name           = var.dynamodb_table_name
  hash_key       = "id"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "id"
    type = "N"
  }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  billing_mode     = "PROVISIONED"

  tags = {
    Name        = "Workshop DynamoDB Table"
    Environment = local.environment
    Project     = local.project_name
  }

  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }
}

## DynamoDB table autoscaling
resource "aws_appautoscaling_target" "messages_table_read_target" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "table/${aws_dynamodb_table.messages_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "messages_table_write_target" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "table/${aws_dynamodb_table.messages_table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "messages_table_read_policy" {
  name               = "Workshop DynamoDB Table Read Policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "table/${aws_dynamodb_table.messages_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70.0
  }
}
resource "aws_appautoscaling_policy" "messages_table_write_policy" {
  name               = "Workshop DynamoDB Table Write Policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "table/${aws_dynamodb_table.messages_table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70.0
  }
}


###########
# Lambda  #
###########

resource "aws_iam_role" "iam_for_lambda" {
  name               = var.lambda_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

resource "aws_iam_role_policy" "lambda_policy" {
  depends_on = [aws_iam_role.iam_for_lambda]
  name       = "${var.lambda_function_name}-policy"
  role       = aws_iam_role.iam_for_lambda.id
  policy     = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_lambda_function" "messages_lambda" {
  depends_on       = [data.archive_file.lambda_zip, aws_iam_role_policy.lambda_policy]
  filename         = "${path.module}/lambda_function.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.messages_table.name
    }
  }

  tags = {
    Name        = "Workshop Lambda"
    Environment = local.environment
    Project     = local.project_name
  }
}




##########
# API GW #
##########

# API gateway to send all types of requests to the lambda function
# API gateway to attach to cloudfront distribution to /api/* path

resource "aws_api_gateway_rest_api" "messages_api" {
  name        = "messages_api"
  description = "Messages API"
}

resource "aws_api_gateway_resource" "messages_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  parent_id   = aws_api_gateway_rest_api.messages_api.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_method" "messages_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
  resource_id   = aws_api_gateway_resource.messages_api_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "messages_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messages_api.id
  resource_id             = aws_api_gateway_resource.messages_api_resource.id
  http_method             = aws_api_gateway_method.messages_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.messages_lambda.invoke_arn
}


resource "aws_api_gateway_deployment" "messages_api_deployment" {
  depends_on        = [aws_api_gateway_integration.messages_api_integration, aws_api_gateway_rest_api.messages_api]
  rest_api_id       = aws_api_gateway_rest_api.messages_api.id
  stage_name        = "api"
  stage_description = "Deployed at ${timestamp()}"

}


resource "aws_cloudfront_origin_access_identity" "cf_api_origin_access_identity" {
  comment = "Allow CloudFront to reach the API Gateway"
}


### Add api gateway trigger to lambda function
resource "aws_lambda_permission" "messages_api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.messages_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.messages_api.id}/*/*/*"
}
