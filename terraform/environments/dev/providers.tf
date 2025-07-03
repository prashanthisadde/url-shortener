provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = "=1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.0.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-backend-common-ps"
    key            = "url-shortener/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tflocks"
  }
}
