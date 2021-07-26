output "cluster_url_alb" {
  description = <<-EOT
    Cluster public URL with schema, domain, and port.
    All parameters depend on inputs values and calculated automatically 
    for convenient use. Can be created separately outside a module
  EOT
  value       = module.vault.cluster_url
}

output "cluster_url_cname" {
  description = <<-EOT
    Cluster public URL assesible by Route53 CNAME
  EOT
  value = replace(
    module.vault.cluster_url,
    module.vault.alb_dns_name,
    aws_route53_record.cname.fqdn
  )
}

output "cluster_url_alias" {
  description = <<-EOT
    Cluster public URL assesible by Route53 Alias
  EOT
  value = replace(
    module.vault.cluster_url,
    module.vault.alb_dns_name,
    aws_route53_record.alias.fqdn
  )
}
