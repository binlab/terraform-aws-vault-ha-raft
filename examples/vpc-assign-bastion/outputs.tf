output "cluster_url" {
  description = <<-EOT
    Cluster public URL with schema, domain, and port.
    All parameters depend on inputs values and calculated automatically 
    for convenient use. Can be created separately outside a module
  EOT
  value       = module.vault.cluster_url
}

output "bastion_host" {
  description = <<-EOT
    Bastion public host (Public IP)
  EOT
  value       = module.bastion.public_ip
}
