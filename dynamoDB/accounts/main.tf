provider "aws" {
  region     = "us-east-1"
}

resource "aws_dynamodb_table" "banter-accounts-table" {
  name           = "banter-accounts-table-${var.env}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "user_email"

  attribute {
    name = "user_email"
    type = "S"
  }

  attribute {
    name = "item_id"
    type = "S"
  }

  global_secondary_index {
    name               = "ItemIdIndex"
    hash_key           = "item_id"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "KEYS_ONLY"
  }
}