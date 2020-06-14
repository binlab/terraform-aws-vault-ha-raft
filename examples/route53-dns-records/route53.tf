# Export Route 53 Zone as a data resource

data aws_route53_zone "example" {
  name         = format("%s.", var.route53_zone)
  private_zone = false
}

# Example CNAME Record

resource aws_route53_record "cname" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = "cname"
  type    = "CNAME"
  ttl     = 300
  records = [module.vault.alb_dns_name]
}

# Example AWS Alias Record

resource aws_route53_record "alias" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = "alias"
  type    = "A"

  alias {
    name                   = module.vault.alb_dns_name
    zone_id                = module.vault.alb_zone_id
    evaluate_target_health = true
  }
}
