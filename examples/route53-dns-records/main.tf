provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Export Route 53 Zone as a data resource

data "aws_route53_zone" "public" {
  name         = format("%s.", var.route53_zone)
  private_zone = false
}

# Public CNAME Record

resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "cname"
  type    = "CNAME"
  ttl     = 300
  records = [module.vault.alb_dns_name]
}

# Public AWS Alias Record

resource "aws_route53_record" "alias" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "alias"
  type    = "A"

  alias {
    name                   = module.vault.alb_dns_name
    zone_id                = module.vault.alb_zone_id
    evaluate_target_health = true
  }
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=v0.1.8"

  cluster_name       = "vault-route53"
  node_instance_type = "t3a.small"
  autounseal         = true
  nat_enabled        = true
}
