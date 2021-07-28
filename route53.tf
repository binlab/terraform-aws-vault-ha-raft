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

resource "aws_route53_record" "ext" {
  count   = var.create_route53_external ? 1 : 0
  zone_id = var.route53_zone_id_external
  name    = "vault"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.cluster.dns_name]
}