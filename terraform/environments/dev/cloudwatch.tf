resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "lambda_failed_invocations" {
  alarm_name          = "lambda-${var.lambda_function_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"

  dimensions = {
    FunctionName = var.lambda_function_name
  }
  treat_missing_data = "notBreaching"
}
