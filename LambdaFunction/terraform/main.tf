provider "aws" {
  region                      = "ap-northeast-1"
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    s3         = "http://localstack:4566"
    apigateway = "http://localstack:4566"
    iam        = "http://localstack:4566"
    lambda     = "http://localstack:4566"
    acm        = "http://localstack:4566"
  }
}


# aws apigateway create-rest-api
resource "aws_api_gateway_rest_api" "tian_photos_api" {
  name = "tain-photos-api"
}

# aws iam create-role
resource "aws_iam_role" "tian_photos_lambda_role" {
  name = "tian-photos-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com",
      },
      Effect = "Allow",
      Sid = "",
    }],
  })
}

# aws iam put-role-policy
resource "aws_iam_role_policy" "tian_photos_lambda_policy" {
  name = "tian-photos-lambda-policy"
  role = aws_iam_role.tian_photos_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "arn:aws:logs:*:*:*",
      Effect = "Allow",
    }],
  })
}

# aws lambda create-function
resource "aws_lambda_function" "example_lambda" {
  function_name = "tianphotos_api_function_uploadservice_functionhandler"
  handler       = "LambdaFunction::LambdaFunction.FunctionEntry::FunctionHandler"
  role          = aws_iam_role.tian_photos_lambda_role.arn
  runtime       = "dotnet6"
  filename      = "out.zip"
}

# aws lambda create-alias
resource "aws_lambda_alias" "live_alias" {
  name             = "LIVE"
  function_name    = aws_lambda_function.example_lambda.function_name
  function_version = "$LATEST"
}

# aws apigateway create-resource
resource "aws_api_gateway_resource" "photos_resource" {
  rest_api_id = aws_api_gateway_rest_api.tian_photos_api.id
  parent_id   = aws_api_gateway_rest_api.tian_photos_api.root_resource_id
  path_part   = "photos"
}

# aws apigateway put-method
resource "aws_api_gateway_method" "photos_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.tian_photos_api.id
  resource_id   = aws_api_gateway_resource.photos_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# aws apigateway put-integration
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.tian_photos_api.id
  resource_id = aws_api_gateway_resource.photos_resource.id
  http_method = aws_api_gateway_method.photos_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

# aws apigateway create-deployment
resource "aws_api_gateway_deployment" "example_deployment" {
  rest_api_id = aws_api_gateway_rest_api.tian_photos_api.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.photos_post_method,
    aws_api_gateway_integration.lambda_integration,
  ]
}

# aws apigateway create-stage
resource "aws_api_gateway_stage" "live_stage" {
  stage_name    = "LIVE"
  rest_api_id   = aws_api_gateway_rest_api.tian_photos_api.id
  deployment_id = aws_api_gateway_deployment.example_deployment.id

  variables = {
    "functionAlias" = "LIVE"
  }
}

# aws lambda add-permission 
resource "aws_lambda_permission" "api_gw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tian_photos_api.execution_arn}/*/*/*"
}
