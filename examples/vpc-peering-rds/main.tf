provider "aws" {
  region = var.aws_region
}

data aws_availability_zones "rds" {
  state = "available"
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=v0.1.4"

  cluster_name        = "vault"
  cluster_count       = 1
  node_instance_type  = "t3a.small"
  autounseal          = true
  ssh_authorized_keys = [file(var.ssh_public_key)]
}

module "bastion" {
  source = "github.com/binlab/terraform-aws-bastion?ref=v0.1.3"

  stack                 = "vault"
  vpc_id                = module.vault.vpc_id
  vpc_subnet_id         = module.vault.public_subnets[0]
  security_groups       = [module.vault.vpc_security_group]
  ec2_ssh_cidr          = ["0.0.0.0/0"]
  bastion_ssh_cidr      = ["0.0.0.0/0"]
  ec2_ssh_auth_keys     = [file(var.ssh_public_key)]
  bastion_ssh_auth_keys = [file(var.ssh_public_key)]
}
