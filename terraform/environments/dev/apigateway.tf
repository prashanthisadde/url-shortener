resource "aws_api_gateway_rest_api" "api" {
  name        = "${local.resource_prefix}-api"
  description = "REST API for the URL shortener - ${var.environment}"
  
  tags = local.tags
}

resource "aws_api_gateway_resource" "shorten" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "shorten"
}

resource "aws_api_gateway_resource" "redirect" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{shortcode}"
}

# Method for POST /shorten
resource "aws_api_gateway_method" "shorten_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.shorten.id
  http_method   = "POST"
  authorization = "NONE"
}

# Method for GET /{shortcode}
resource "aws_api_gateway_method" "redirect_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.redirect.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration (Lambda) for POST /shorten
resource "aws_api_gateway_integration" "shorten_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.shorten.id
  http_method = aws_api_gateway_method.shorten_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.url-shortener.invoke_arn
}

# Integration (Lambda) for GET /{shortcode}
resource "aws_api_gateway_integration" "redirect_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.redirect.id
  http_method = aws_api_gateway_method.redirect_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.url-shortener.invoke_arn
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.shorten_post,
    aws_api_gateway_integration.redirect_get
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "v1" {
  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

# Lambda permission for API Gateway to invoke
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url-shortener.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
