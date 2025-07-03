resource "aws_dynamodb_table" "urls" {
  name         = "${local.resource_prefix}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "shortcode"

  attribute {
    name = "shortcode"
    type = "S"
  }

  tags = local.tags
}
