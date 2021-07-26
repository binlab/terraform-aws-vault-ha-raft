variable "aws_region" {
  description = <<-EOT
    AWS Region name
  EOT
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = <<-EOT
    AWS Profile
  EOT
  type        = string
  default     = "default"
}

variable "ssh_public_key_path" {
  description = <<-EOT
    Path to SSH public key in a HOME directory
  EOT
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vault_vpc_cidr" {
  description = <<-EOT
    VPC CIDR assigned to Vault cluster
  EOT
  type        = string
  default     = "172.31.31.0/24"
}

variable "vault_vpc_public_subnets" {
  description = <<-EOT
    VPC public subnets assigned to Vault cluster
  EOT
  type        = set(string)
  default = [
    "172.31.31.0/28",
    "172.31.31.16/28",
    "172.31.31.32/28",
  ]
}

variable "vault_vpc_private_subnets" {
  description = <<-EOT
    VPC private subnets assigned to Vault cluster
  EOT
  type        = set(string)
  default = [
    "172.31.31.128/28",
    "172.31.31.144/28",
    "172.31.31.160/28",
  ]
}

variable "main_vpc_cidr" {
  description = <<-EOT
    Main VPC CIDR created separately. Block sizes must be between a 
    /16 netmask and /28 netmask for AWS. For example: 
    `10.0.0.0/16-10.0.0.0/28`,
    `172.16.0.0/16-172.16.0.0/28`,
    `192.168.0.0/16-192.168.0.0/28`
  EOT
  type        = string
  default     = "10.0.0.0/16"
}

variable "main_vpc_subnet_cidr" {
  description = <<-EOT
    CIDR block for VPC subnets, must be canonical form, be in the same 
    network with VPC and non-overlapping with other subnets. For example:
    subnet `/25`, (e.g. `172.31.31.0/25`) can contain up to 16 subnets 
    with a mask `/28` (subnet mask must be not less than `/28` for AWS)
  EOT
  type        = string
  default     = "10.0.0.0/25"
}

variable "main_vpc_subnet_mask" {
  description = <<-EOT
    Size of VPC subnets. The subnet mask must be not less than `/28` 
    for AWS. Mask /28 can contain up to 16 IP addresses but AWS reserved 
    5 addresses so 11 available for user. More: 
    https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
  EOT
  type        = number
  default     = 28
}
