resource "aws_iam_role" "main" {
  name                = "ServerlessChat"
  assume_role_policy  = file("./policies/assume-role.json")
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
