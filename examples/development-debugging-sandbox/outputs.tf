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

output "ssh_connection_commands" {
  description = <<-EOT
    Fast CLI commands for connection to nodes
  EOT
  value = { for i in range(0, var.cluster_count)
    : format("node%d", i) => format(
      "ssh -o StrictHostKeyChecking=no -J core@%s core@node%d.vault.int -t 'sudo su'",
      module.bastion.public_ip,
      i
    )
  }
}

