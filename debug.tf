/*
resource local_file "ssh_private_key" {
  count = var.debug ? length(tls_private_key.core) : 0

  filename        = format("%s/root-ssh.pem", local.debug_path)
  file_permission = "0600"
  content         = tls_private_key.core[0].private_key_pem
}
*/
resource local_file "node_cert" {
  count = var.debug ? length(tls_locally_signed_cert.node) : 0

  filename        = format("%s/node-%d.cert", local.debug_path, count.index)
  file_permission = "0600"
  content         = tls_locally_signed_cert.node[count.index].cert_pem
}

resource local_file "node_key" {
  count = var.debug ? length(tls_private_key.node) : 0

  filename        = format("%s/node-%d.key", local.debug_path, count.index)
  file_permission = "0600"
  content         = tls_private_key.node[count.index].private_key_pem
}

resource local_file "ca_cert" {
  count = var.debug ? 1 : 0

  filename        = format("%s/node-ca.cert", local.debug_path)
  file_permission = "0600"
  content         = tls_self_signed_cert.ca.cert_pem
}

resource local_file "user_data" {
  count = var.debug ? length(data.ignition_config.node) : 0

  filename        = format("%s/userdata-%d.json", local.debug_path, count.index)
  file_permission = "0600"
  content         = data.ignition_config.node[count.index].rendered
}

resource local_file "config" {
  count = var.debug ? length(data.ignition_file.config) : 0

  filename        = format("%s/config-%d.yaml", local.debug_path, count.index)
  file_permission = "0600"
  content = yamlencode(
    jsondecode(
      base64decode(
        split(",",
          jsondecode(data.ignition_file.config[count.index].rendered)["contents"]["source"]
        )[1]
      )
    )
  )
}
