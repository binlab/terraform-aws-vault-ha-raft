resource "aws_route53_zone" "int" {
  name          = var.internal_zone
  comment       = "Private zone for Vault HA Cluster"
  force_destroy = true

  vpc {
    vpc_id = local.vpc_id
  }

  tags = merge(local.tags, {
    Description = "Private zone for Vault HA"
    Name        = format(local.name_tmpl, "int")
  })
}

resource "aws_route53_record" "int" {
  count = var.cluster_count

  zone_id = aws_route53_zone.int.zone_id
  name    = format(local.internal_domain_tmpl, count.index)
  type    = "A"
  ttl     = "60"

  records = [
    aws_instance.node[count.index].private_ip,
  ]
}

resource "aws_route53_record" "cname" {
  count = (var.route53_record_create
    && var.route53_record_type == "cname" ? 1 : 0
  )

  zone_id = var.route53_zone_id
  name    = var.route53_record_name
  type    = "CNAME"
  ttl     = var.route53_record_ttl

  records = [
    aws_lb.cluster.dns_name
  ]
}

resource "aws_route53_record" "alias" {
  count = (var.route53_record_create
    && var.route53_record_type == "alias" ? 1 : 0
  )

  zone_id = var.route53_zone_id
  name    = var.route53_record_name
  type    = "A"

  alias {
    name                   = aws_lb.cluster.dns_name
    zone_id                = aws_lb.cluster.zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "external" {
  count = var.route53_zone_id != "" ? 1 : 0

  zone_id = var.route53_zone_id
}
