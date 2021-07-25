provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Determinate own outside IP for external requests
# needed just for restricting security group by request IP

data "http" "outside_ip" {
  count = var.restrict_ssh_port ? 1 : 0

  url = "https://api.ipify.org?format=json"

  request_headers = {
    Accept = "application/json"
  }
}

# Generate OpenSSH key pair by Terraform for SSH connection.
# Just an example of generating OpenSSH pair by Terraform as an external 
# resource. Useful if you need provide the same SSH key for other 
# resources in your infrastructure. But not so good solution from a
# security perspective. See "Important Security Notice" here:
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key

resource "tls_private_key" "vault_ssh" {
  count = var.ssh_key_source == "external" ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

# Put OpenSSH private key to the local filesystem with a right permission.
# Example of convinient way to storing SSH key on local filesystem. But
# not so good solution from a security perspective. 
# See "Important Security Notice" here:
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key

resource "local_file" "ssh_private_key" {
  count = var.ssh_key_source != "filesystem" ? 1 : 0

  filename             = pathexpand("~/.ssh/vault-ssh_rsa")
  file_permission      = "0600"
  directory_permission = "0775"

  sensitive_content = (var.ssh_key_source == "external"
    ? tls_private_key.vault_ssh[0].private_key_pem
    : module.vault.ssh_private_key
  )
}

# Obtain public OpenSSH key from filesystem the better way from a 
# security perspective. In Terraform state file just will save a public 
# key which not sensitive information. Important: file "~/.ssh/id_rsa.pub" 
# should exist on filesystem before terraform apply

data "local_file" "ssh_private_key" {
  count = var.ssh_key_source == "filesystem" ? 1 : 0

  filename = pathexpand("~/.ssh/id_rsa.pub")
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=master"

  cluster_name       = "vault-public-ssh"
  node_instance_type = "t3a.small"
  autounseal         = true
  nat_enabled        = false
  node_allow_public  = true

  ssh_allowed_subnets = [(var.restrict_ssh_port
    ? format("%s/32", jsondecode(data.http.outside_ip[0].body)["ip"])
    : "0.0.0.0/0"
  )]

  ssh_authorized_keys = [(var.ssh_key_source == "external"
    ? tls_private_key.vault_ssh[0].public_key_openssh
    : var.ssh_key_source == "filesystem"
    ? data.local_file.ssh_private_key[0].content
    : ""
  )]
}
