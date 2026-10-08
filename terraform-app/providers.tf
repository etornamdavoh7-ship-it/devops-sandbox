terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Use remote backend to store the state file in S3 bucket
  backend "s3" {
    bucket         = "devops-sandbox-terraform-state-96a110b7"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-sandbox-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Sandbox"
      Project     = "DevOps-ECS-App"
      ManagedBy   = "Terraform"
    }
  }
}