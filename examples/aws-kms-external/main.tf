provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_kms_key" "external" {
  description             = "Vault HA Cluster External Key"
  deletion_window_in_days = 7

  tags = {
    Name = "Vault-HA-Cluster-External-Key"
  }
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=master"

  cluster_name       = "vault-kms"
  node_instance_type = "t3a.small"
  autounseal         = true
  kms_key_create     = false
  kms_key_arn        = aws_kms_key.external.arn
  nat_enabled        = true
  vpc_cidr           = "172.31.31.0/24"

  vpc_public_subnets = [
    "172.31.31.0/28",
    "172.31.31.16/28",
    "172.31.31.32/28",
  ]

  vpc_private_subnets = [
    "172.31.31.128/28",
    "172.31.31.144/28",
    "172.31.31.160/28",
  ]
}
