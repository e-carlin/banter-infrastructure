provider "aws" {
  region     = "us-east-1"
}

resource "aws_dynamodb_table" "banter-institutions-table" {
  name           = "banter-institutions-table-${var.env}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "item_id"

  attribute {
    name = "item_id"
    type = "S"
  }

  attribute {
    name = "user_email"
    type = "S"
  }

  global_secondary_index {
    name               = "UserEmailIndex"
    hash_key           = "user_email"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "KEYS_ONLY"
  }
}