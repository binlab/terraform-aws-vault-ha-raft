provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=v0.1.8"

  cluster_name       = "vault-ext-vpc"
  cluster_count      = 3
  node_instance_type = "t3a.small"
  autounseal         = true
  nat_enabled        = true

  vpc_id_external         = data.aws_vpc.default.id
  vpc_public_subnet_cidr  = "172.31.128.0/25"
  vpc_public_subnet_mask  = 28
  vpc_private_subnet_cidr = "172.31.128.128/25"
  vpc_private_subnet_mask = 28
}
