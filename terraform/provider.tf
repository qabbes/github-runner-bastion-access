terraform {
  required_version = ">= 1.11.0"

  backend "s3" {
    bucket       = "gha-bastion-access-state-bucket-qabbes"
    key          = "global/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_subnet" {
  default_for_az = true
}