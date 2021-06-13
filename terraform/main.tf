terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket = "hi1280-tfstate-main"
    key    = "aws-lambda-container-cicd-example.tfstate"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

provider "aws" {}