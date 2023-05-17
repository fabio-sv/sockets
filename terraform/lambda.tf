
resource "aws_lambda_function" "connect_lambda" {
  function_name = "connect"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs16.x"
  handler       = "connect.handler"

  filename         = "${path.module}/zips/connect.zip"
  source_code_hash = filebase64sha256("${path.module}/zips/connect.zip")
}

resource "aws_lambda_function" "disconnect_lambda" {
  function_name = "disconnect"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs16.x"
  handler       = "disconnect.handler"

  filename         = "${path.module}/zips/disconnect.zip"
  source_code_hash = filebase64sha256("${path.module}/zips/disconnect.zip")
}

resource "aws_lambda_function" "send_message_lambda" {
  function_name = "sendmessage"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs16.x"
  handler       = "send-message.handler"

  filename         = "${path.module}/zips/send-message.zip"
  source_code_hash = filebase64sha256("${path.module}/zips/send-message.zip")
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
  ]

  # Didn't know you could do this
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "lambda-policy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_lambda_permission" "connect_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connect_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gw.execution_arn}/*/*"
}

resource "aws_lambda_permission" "disconnect_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.disconnect_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gw.execution_arn}/*/*"
}

resource "aws_lambda_permission" "send_message_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_message_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gw.execution_arn}/*/*"
}
