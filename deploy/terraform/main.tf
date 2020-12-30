provider "aws" {
  region  = "eu-central-1"
  version = "~> 3.11"
}

terraform {
  required_version = "~> 0.13"
}

data "aws_region" "current" {}          # To get aws region: data.aws_region.current.name
data "aws_caller_identity" "current" {} # To get aws account: data.aws_caller_identity.current.account_id