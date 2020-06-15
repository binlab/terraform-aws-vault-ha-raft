output "bastion_host" {
  value = module.bastion.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}
