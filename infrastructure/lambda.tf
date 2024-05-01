locals {
  functions = [
    "connect",
    "disconnect",
    "send"
  ]
}

resource "aws_lambda_function" "main" {
  for_each = { for fn in local.functions : fn => fn }

  function_name = each.value
  role          = aws_iam_role.main.arn
  runtime       = "python3.9"
  handler       = "${each.value}.handler"

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.connections.name
      API_ENDPOINT = aws_apigatewayv2_stage.main.invoke_url
    }
  }

  filename         = "./functions.zip"
  source_code_hash = filebase64sha256("./functions.zip")
}

resource "aws_lambda_permission" "connect_lambda_permission" {
  for_each = aws_lambda_function.main

  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = each.value.function_name
}
