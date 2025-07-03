data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../modules/url-shortener"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "url-shortener" {
  function_name    = local.resource_prefix
  handler          = "bootstrap"
  runtime          = "provided.al2"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  
  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.urls.name
      ENVIRONMENT = var.environment
    }
  }
  
  tags = local.tags
}
