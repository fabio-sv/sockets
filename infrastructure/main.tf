locals {
  functions = [
    "connect",
    "disconnect",
    "send"
  ]
}

resource "aws_iam_role" "main" {
  name                = "ServerlessChat"
  assume_role_policy  = file("./policies/assume-role.json")
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_s3_bucket" "main" {
  bucket = "serverless-chat-room"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = templatefile("./policies/bucket.json", {
    bucket_arn     = aws_s3_bucket.main.arn
    cloudfront_arn = aws_cloudfront_distribution.main.arn
  })
}

resource "aws_dynamodb_table" "main" {
  name           = "serverless-table"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }
}

resource "aws_lambda_function" "connect" {
  function_name = "connect"
  role          = aws_iam_role.main.arn
  runtime       = "python3.9"
  handler       = "connect.handler"

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.main.name
      API_ENDPOINT = aws_apigatewayv2_stage.main.invoke_url
    }
  }

  filename         = "./functions.zip"
  source_code_hash = filebase64sha256("./functions.zip")
}

resource "aws_lambda_function" "disconnect" {
  function_name = "disconnect"
  role          = aws_iam_role.main.arn
  runtime       = "python3.9"
  handler       = "disconnect.handler"

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.main.name
      API_ENDPOINT = aws_apigatewayv2_stage.main.invoke_url
    }
  }

  filename         = "./functions.zip"
  source_code_hash = filebase64sha256("./functions.zip")
}

resource "aws_lambda_function" "send" {
  function_name = "send"
  role          = aws_iam_role.main.arn
  runtime       = "python3.9"
  handler       = "send.handler"

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.main.name
      API_ENDPOINT = aws_apigatewayv2_stage.main.invoke_url
    }
  }

  filename         = "./functions.zip"
  source_code_hash = filebase64sha256("./functions.zip")
}

resource "aws_lambda_permission" "main" {
  for_each = { for fn in local.functions : fn => fn }

  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = each.value
}

resource "aws_apigatewayv2_api" "main" {
  name                       = "ServerlessChatGateway"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "dev"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 50
  }
}

resource "aws_apigatewayv2_integration" "main" {
  for_each = {
    connect    = aws_lambda_function.connect,
    send       = aws_lambda_function.send,
    disconnect = aws_lambda_function.disconnect
  }

  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"

  integration_uri           = each.value.invoke_arn
  credentials_arn           = aws_iam_role.main.arn
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "main" {
  for_each = {
    connect    = aws_lambda_function.connect,
    send       = aws_lambda_function.send,
    disconnect = aws_lambda_function.disconnect
  }

  api_id    = aws_apigatewayv2_api.main.id
  route_key = contains(["connect", "disconnect"], each.value.function_name) ? format("$%s", each.value.function_name) : each.value.function_name
  target    = "integrations/${aws_apigatewayv2_integration.main[each.key].id}"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.main["connect"].id}"
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "CFAccessControl"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = "main"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "main"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["ZA"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}
