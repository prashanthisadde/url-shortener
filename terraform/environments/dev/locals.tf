locals {
  resource_prefix = "${var.lambda_function_name}-${var.environment}"
  
  # Common tags with environment
  tags = merge(var.common_tags, {
    Environment = var.environment
  })
}
