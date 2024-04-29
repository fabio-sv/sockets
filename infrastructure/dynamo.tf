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
