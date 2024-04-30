terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      "Application" = "ServerlessChat"
      "Environment" = "Development"
      "Purpose"     = "Live-Demo"
      "CreatedBy"   = "Terraform"
      "Owner"       = "fabiosv@bbd.co.za"
      "DestroyBy"   = "2024-04-05"
    }
  }
}

data "aws_caller_identity" "current" {}

output "cloudfront_url" {
  description = "URL of CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "api_url" {
  description = "URL of API Gateway"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "bucket_name" {
  description = "Name of S3 bucket"
  value       = aws_s3_bucket.main.bucket
}
