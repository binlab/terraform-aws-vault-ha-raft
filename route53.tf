resource aws_route53_zone "int" {
  name          = var.internal_zone
  comment       = "Private zone for Vault HA Cluster"
  force_destroy = true

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = merge(local.tags, {
    Description = "Private zone for Vault HA"
    Name        = format(local.name_tmpl, "int")
  })
}

resource aws_route53_record "int" {
  count = var.cluster_count

  zone_id = aws_route53_zone.int.zone_id
  name    = format(local.internal_domain_tmpl, count.index)
  type    = "A"
  ttl     = "60"

  records = [
    aws_instance.node[count.index].private_ip,
  ]
}
