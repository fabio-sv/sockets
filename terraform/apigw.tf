data "aws_iam_policy_document" "gw_policy_doc" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    effect = "Allow"
    resources = [
      aws_lambda_function.connect_lambda.arn,
      aws_lambda_function.disconnect_lambda.arn,
      aws_lambda_function.send_message_lambda.arn
    ]
  }
}

resource "aws_iam_policy" "gw_policy" {
  name   = "WsMessengerAPIGatewayPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.gw_policy_doc.json
}

resource "aws_iam_role" "gw_role" {
  name = "WebSocketAPIGatewayRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.gw_policy.arn]
}

resource "aws_apigatewayv2_api" "gw" {
  name                       = "socketed-chat-gateway"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.gw.id
  name        = "dev"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 50
  }
}

resource "aws_apigatewayv2_integration" "connect_integration" {
  api_id           = aws_apigatewayv2_api.gw.id
  integration_type = "AWS_PROXY"

  integration_uri           = aws_lambda_function.connect_lambda.invoke_arn
  credentials_arn           = aws_iam_role.gw_role.arn
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.gw.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.connect_integration.id}"
}

resource "aws_apigatewayv2_integration" "disconnect_integration" {
  api_id           = aws_apigatewayv2_api.gw.id
  integration_type = "AWS_PROXY"

  integration_uri           = aws_lambda_function.disconnect_lambda.invoke_arn
  credentials_arn           = aws_iam_role.gw_role.arn
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.gw.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.disconnect_integration.id}"
}

resource "aws_apigatewayv2_integration" "send_message_integration" {
  api_id           = aws_apigatewayv2_api.gw.id
  integration_type = "AWS_PROXY"

  integration_uri           = aws_lambda_function.send_message_lambda.invoke_arn
  credentials_arn           = aws_iam_role.gw_role.arn
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "send_message_route" {
  api_id    = aws_apigatewayv2_api.gw.id
  route_key = "sendmessage"
  target    = "integrations/${aws_apigatewayv2_integration.send_message_integration.id}"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.gw.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.connect_integration.id}"
}
