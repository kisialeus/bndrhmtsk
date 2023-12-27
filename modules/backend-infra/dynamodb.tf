resource "aws_dynamodb_table" "terraform-lock" {
  name           = var.dynamodb.name
  read_capacity  = var.dynamodb.read_capacity
  write_capacity = var.dynamodb.write_capacity
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}
