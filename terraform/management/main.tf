terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40.1"
    }
  }
  backend "s3" {
    encrypt = true
    key     = "<terraform-state-key>"
    bucket  = "<terraform-state-bucket>"
    region  = "<terraform-state-region>"
  }
}

provider "aws" {
  region = var.aws["region"]
}