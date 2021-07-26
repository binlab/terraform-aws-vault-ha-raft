output "cluster_url" {
  description = <<-EOT
    Cluster public URL with schema, domain, and port.
    All parameters depend on inputs values and calculated automatically 
    for convenient use. Can be created separately outside a module
  EOT
  value       = module.vault.cluster_url
}

output "igw_public_ips" {
  description = <<-EOT
    List of Internet public IPs. If cluster nodes are determined to be 
    in the public subnet (Internet Gateway used) all external network 
    requests will be via public IPs assigned to the nodes. This list 
    can be used for configuring security groups of related services or 
    connect to the nodes via SSH on debugging
  EOT
  value       = module.vault.igw_public_ips
}
