provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_vpc" "default" {
  default = true
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=master"

  cluster_name       = "vault-def-vpc"
  cluster_count      = 3
  node_instance_type = "t3a.small"
  autounseal         = true
  nat_enabled        = true

  vpc_id_external              = data.aws_vpc.default.id
  internet_gateway_id_external = data.aws_internet_gateway.default.id
  vpc_public_subnet_cidr       = "172.31.128.0/25"
  vpc_public_subnet_mask       = 28
  vpc_private_subnet_cidr      = "172.31.128.128/25"
  vpc_private_subnet_mask      = 28
}
