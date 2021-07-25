provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Configuring ACM certificate

resource aws_acm_certificate "vault" {
  validation_method = "DNS"
  domain_name = format("%s.%s",
    var.domain_prefix,
    var.route53_zone
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Configure Route53 Zone as a data resource

data "aws_route53_zone" "public" {
  name         = format("%s.", var.route53_zone)
  private_zone = false
}

# Configure CNAME Record to ALB

resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.domain_prefix
  type    = "CNAME"
  ttl     = 60
  records = [module.vault.alb_dns_name]
}

# Configure ACM Record to ALB

resource "aws_route53_record" "acm" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = aws_acm_certificate.vault.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.vault.domain_validation_options[0].resource_record_type
  ttl     = 60
  records = [aws_acm_certificate.vault.domain_validation_options[0].resource_record_value]
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=v0.1.8"

  cluster_name       = "vault-ha-acm"
  node_instance_type = "t3a.small"
  autounseal         = true
  nat_enabled        = true
  cluster_domain     = aws_acm_certificate.vault.domain_name
  certificate_arn    = aws_acm_certificate.vault.arn
}
