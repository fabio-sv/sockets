resource "aws_s3_bucket" "main" {
  bucket = "my-super-duper-cool-bucket"

  force_destroy = true
}

resource "aws_dynamodb_table" "connections" {
  name           = "ServerlessChatConnectionTable"
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
      TABLE_NAME   = aws_dynamodb_table.connections.name
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
      TABLE_NAME   = aws_dynamodb_table.connections.name
      API_ENDPOINT = aws_apigatewayv2_stage.main.invoke_url
    }
  }
}

resource "aws_lambda_function" "send" {
  function_name = "send"
  role          = aws_iam_role.main.arn
  runtime       = "python3.9"
  handler       = "send.handler"

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.connections.name
      API_ENDPOINT = aws_apigatewayv2_stage.main.invoke_url
    }
  }
}
