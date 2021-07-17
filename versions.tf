terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.53.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.1.1"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "= 1.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.4.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/Jerry/.aws/credentials"
}