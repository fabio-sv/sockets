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
  for_each = aws_lambda_function.main

  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"

  integration_uri           = each.value.invoke_arn
  credentials_arn           = aws_iam_role.main.arn
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "main" {
  for_each = aws_lambda_function.main

  api_id    = aws_apigatewayv2_api.main.id
  route_key = each.value.function_name
  target    = "integrations/${aws_apigatewayv2_integration.main[each.key].id}"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.main["connect"].id}"
}
