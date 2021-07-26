provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "current" {
  state = "available"
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=v0.1.8"

  cluster_name        = "vault-peering"
  cluster_count       = 1
  node_instance_type  = "t3a.small"
  autounseal          = true
  nat_enabled         = true
  ssh_authorized_keys = [data.local_file.ssh_public_key.content]
  vpc_cidr            = var.vault_vpc_cidr
  vpc_public_subnets  = var.vault_vpc_public_subnets
  vpc_private_subnets = var.vault_vpc_private_subnets
}

module "bastion" {
  source = "github.com/binlab/terraform-aws-bastion?ref=v0.1.5"

  stack                 = "vault"
  vpc_id                = module.vault.vpc_id
  vpc_subnet_id         = module.vault.public_subnets[0]
  security_groups       = [module.vault.vpc_security_group]
  ec2_ssh_cidr          = ["0.0.0.0/0"]
  bastion_ssh_cidr      = ["0.0.0.0/0"]
  ec2_ssh_auth_keys     = [data.local_file.ssh_public_key.content]
  bastion_ssh_auth_keys = [data.local_file.ssh_public_key.content]
}
