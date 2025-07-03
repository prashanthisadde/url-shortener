resource "aws_wafv2_web_acl" "url_shortener_acl" {
  name  = "${local.resource_prefix}-waf"
  scope = "REGIONAL"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.resource_prefix}WAF"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "RateLimit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }
  
  tags = local.tags
}

resource "aws_wafv2_web_acl_association" "waf_apigateway" {
  resource_arn = aws_api_gateway_stage.v1.arn
  web_acl_arn  = aws_wafv2_web_acl.url_shortener_acl.arn
}
