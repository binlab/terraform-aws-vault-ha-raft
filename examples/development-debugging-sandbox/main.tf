provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

module "bastion" {
  source = "github.com/binlab/terraform-aws-bastion?ref=v0.1.5"

  stack                 = "vault-debug"
  vpc_id                = module.vault.vpc_id
  vpc_subnet_id         = module.vault.public_subnets[0]
  security_groups       = [module.vault.node_security_group]
  ec2_ssh_cidr          = ["0.0.0.0/0"]
  bastion_ssh_cidr      = ["0.0.0.0/0"]
  ec2_ssh_auth_keys     = [data.local_file.ssh_public_key.content]
  bastion_ssh_auth_keys = [data.local_file.ssh_public_key.content]

  ami_image = "ami-0ad034613130b6344"
}


module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=master"

  cluster_name        = "vault-debug"
  cluster_count       = var.cluster_count
  node_instance_type  = "t3a.small"
  autounseal          = true
  nat_enabled         = true
  ssh_authorized_keys = [data.local_file.ssh_public_key.content]
  vpc_cidr            = "172.31.31.0/24"

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

  debug      = true
  debug_path = format("%s/.debug", path.module)
  docker_tag = "1.8.0"

  # ami_image = "ami-0ad034613130b6344"
}
