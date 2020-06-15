variable "aws_region" {
  description = <<-EOT
    AWS Region
  EOT
  type        = string
  default     = "us-east-1"
}

variable "route53_zone" {
  description = <<-EOT
    Name of existing public Route 53 Zone
  EOT
  type        = string
  default     = "example.io"
}
