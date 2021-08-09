resource "aws_kms_key" "autounseal" {
  count = var.autounseal && var.kms_key_create ? 1 : 0

  description             = "Vault Auto-Unseal KMS Key"
  deletion_window_in_days = 10

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "autounseal")
  })
}
