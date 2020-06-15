variable "aws_region" {
  description = <<-EOT
    AWS Region name
  EOT
  type        = string
  default     = "us-east-1"
}

variable "ssh_public_key" {
  description = <<-EOT
    Path to SSH public key in a HOME directory
  EOT
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
