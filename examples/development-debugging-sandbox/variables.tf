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

variable "cluster_count" {
  description = <<-EOT
    Count of Nodes in Cluster
  EOT
  type        = number
  default     = 3
}

variable "ssh_public_key_path" {
  description = <<-EOT
    Path to SSH public key in a HOME directory
  EOT
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
