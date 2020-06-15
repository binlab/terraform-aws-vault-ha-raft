provider "aws" {
  region = var.aws_region
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=v0.1.3"

  cluster_name       = "vault"
  node_instance_type = "t3a.small"
  autounseal         = true
}
