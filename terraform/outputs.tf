output "connection_url" {
  description = "Endpoint of Dev stage"
  value       = aws_apigatewayv2_api.gw.api_endpoint
}

output "dynamo_db_name" {
  description = "Name of DynamoDB Table"
  value       = aws_dynamodb_table.connections.name
}
