# ============================================================
# REMOTE BACKEND — S3 bucket stores .tfstate, DynamoDB locks it
# Run ONCE manually: aws s3 mb s3://my-tf-state-bucket-<your-account-id>
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-tf-state-bucket-123456789"   # <-- apna bucket name dalo
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"           # prevents concurrent runs
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "sow-infra"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
