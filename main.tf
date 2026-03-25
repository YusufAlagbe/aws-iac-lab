# --------------------------------------------------------------------------
# main.tf — Provider configuration and optional remote-state backend
# --------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: uncomment to use S3 remote state
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "aws-iac-lab/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-iac-lab"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}
