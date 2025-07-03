variable "aws_region" {
  default = "us-east-1"
}

variable "lambda_function_name" {
  default = "url-shortener"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "waf_rate_limit" {
  description = "WAF rate limit per IP per minute"
  type        = number
  default     = 500
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project   = "url-shortener"
    ManagedBy = "terraform"
  }
}
