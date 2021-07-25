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

variable "ssh_key_source" {
  description = <<-EOT
    Determine external SSH key will be used or internal
    internal | external | filesystem
  EOT
  type        = string
  default     = "external"
}

variable "restrict_ssh_port" {
  description = <<-EOT
    Determine to restrict connection to SSH port by AWS security group 
    just for request host IP
  EOT
  type        = bool
  default     = true
}
