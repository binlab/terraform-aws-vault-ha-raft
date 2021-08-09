output "cluster_url" {
  description = <<-EOT
    Cluster public URL with schema, domain, and port.
    All parameters depend on inputs values and calculated automatically 
    for convenient use. Can be created separately outside a module
  EOT
  value       = module.vault.cluster_url
}

output "kms_key_arn" {
  description = <<-EOT
    ARN of AWS KMS Key. It can return arn of internal created key or 
    just forward arn of an external key if it provided by "kms_key_arn" 
    variable. It will return null if "autounseal=true".
  EOT
  value       = module.vault.kms_key_arn
}
