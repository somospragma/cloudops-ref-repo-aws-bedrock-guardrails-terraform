###########################################
############ AWS Provider #################
###########################################

provider "aws" {
  region = "us-east-1"

  # assume_role {
  #   role_arn = "arn:aws:iam::123456789012:role/deployment-role"
  # }
}

###########################################
#Version definition - Terraform - Providers
###########################################

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.24"
    }
  }
}
