output "rest_api_url" {
  description = "URL of the REST API"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.v1.stage_name}"
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "lambda_function_name" {
  description = "Name of the Lambda function" 
  value       = aws_lambda_function.url-shortener.function_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.urls.name
}
