data "ignition_user" "core" {
  name = "core"
  uid  = 500
  ssh_authorized_keys = (
    local.ssh_authorized_keys ? var.ssh_authorized_keys : [
      tls_private_key.core[0].public_key_openssh
    ]
  )
}

data "ignition_user" "admin" {
  count = local.ca_ssh_public_keys ? 1 : 0

  name = "admin"
  uid  = 1000
}

data "ignition_file" "sshd_config" {
  count = local.ca_ssh_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/sshd_config"
  mode       = 384 ### 0600
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = <<-EOT
      Port ${var.ssh_port} 
      UsePrivilegeSeparation sandbox
      ClientAliveInterval 180
      UseDNS no
      UsePAM yes
      PermitRootLogin no
      AllowUsers core admin
      AuthenticationMethods publickey
      TrustedUserCAKeys /etc/ssh/ssh_ca_rsa_keys.pub
      AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u
    EOT
  }
}

data "ignition_file" "auth_principals_core" {
  count = local.ca_ssh_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/auth_principals/core"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.ssh_core_principals)
  }
}

data "ignition_file" "auth_principals_admin" {
  count = local.ca_ssh_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/auth_principals/admin"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.ssh_admin_principals)
  }
}

data "ignition_file" "ca_ssh_public_keys" {
  count = local.ca_ssh_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/ssh_ca_rsa_keys.pub"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.ca_ssh_public_keys)
  }
}

data "ignition_file" "ca_tls_public_keys" {
  count = local.ca_tls_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssl/certs/root-ca.pem"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.ca_tls_public_keys)
  }
}

data "ignition_file" "config" {
  count = var.cluster_count

  filesystem = "root"
  path       = "/etc/vault/config.json"
  mode       = 256 ### 0400
  uid        = 0
  gid        = 0
  content {
    mime = "text/plain"
    content = jsonencode(merge(
      {
        ui            = var.vault_ui
        disable_mlock = var.disable_mlock
        api_addr      = local.cluster_url
        cluster_addr  = format(local.internal_url_tmpl, count.index, var.peer_port)
        listener = [{
          tcp = {
            address                  = format("0.0.0.0:%d", var.node_port)
            cluster_address          = format("0.0.0.0:%d", var.peer_port)
            tls_disable              = false
            tls_min_version          = "tls12"
            tls_key_file             = "/vault/config/node.key"
            tls_cert_file            = "/vault/config/node.cert"
            tls_client_ca_file       = "/vault/config/node-ca.cert"
            tls_disable_client_certs = false
          }
        }]
        storage = {
          raft = {
            path    = "/vault/file/"
            node_id = format(var.node_name_tmpl, count.index)
            retry_join = var.cluster_count > 1 ? [
              for i in range(var.cluster_count) : {
                leader_api_addr    = format(local.internal_url_tmpl, i, var.node_port)
                leader_ca_cert     = ""
                leader_client_cert = ""
                leader_client_key  = ""
              } if i != count.index
            ] : [{}]
          }
        }
      },
      (
        var.autounseal ? local.autounseal : (
          length(var.seal_awskms) != 0 ? local.seal_awskms : (
            length(var.seal_transit) != 0 ? local.seal_transit : {}
          )
        )
      )
    ))
  }
}

data "ignition_filesystem" "data" {
  name = "vault"
  mount {
    device          = "/dev/sdh"
    format          = "ext4"
    wipe_filesystem = false
  }
}

data "ignition_systemd_unit" "mount" {
  name    = "vault.mount"
  content = <<-EOT
    [Unit]
    Before=vault.service
    [Mount]
    What=/dev/sdh
    Where=/vault
    Type=ext4
    [Install]
    WantedBy=vault.service
  EOT
}

data "ignition_file" "helper" {
  count = var.cluster_count > 1 ? 1 : 0

  filesystem = "root"
  path       = "/etc/vault/helper"
  mode       = 320 ### 0500
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = <<-EOT
    #!/bin/sh

    tmp=$(mktemp)

    jq --arg s "$(cat /etc/vault/node-ca.cert)" \
      '.storage.raft.retry_join[].leader_ca_cert = $s' \
      /etc/vault/config.json > "$tmp" && mv "$tmp" /etc/vault/config.json

    jq --arg s "$(cat /etc/vault/node.key)" \
      '.storage.raft.retry_join[].leader_client_key = $s' \
      /etc/vault/config.json > "$tmp" && mv "$tmp" /etc/vault/config.json

    jq --arg s "$(cat /etc/vault/node.cert)" \
      '.storage.raft.retry_join[].leader_client_cert = $s' \
      /etc/vault/config.json > "$tmp" && mv "$tmp" /etc/vault/config.json

    chmod 0400 /etc/vault/config.json 
    EOT
  }
}

data "ignition_systemd_unit" "service" {
  name    = "vault.service"
  content = <<-EOT
    [Unit]
    Description="Hashicorp Vault HA"
    [Service]
    ${var.cluster_count > 1 ? "ExecStartPre=/etc/vault/helper" : ""}
    ExecStartPre=-/usr/bin/rkt rm --uuid-file="/var/cache/vault-service.uuid"
    ExecStart=/usr/bin/rkt run \
      --insecure-options=image \
      --volume vault-data,kind=host,source=/vault,readOnly=false \
      --mount volume=vault-data,target=/vault/file \
      --volume vault-logs,kind=empty,readOnly=false \
      --mount volume=vault-logs,target=/vault/logs \
      --volume vault-config,kind=host,source=/etc/vault,readOnly=true \
      --mount volume=vault-config,target=/vault/config \
      ${format("%s:%s", var.docker_repo, var.docker_tag)} \
      --name=vault \
      --user=0 \
      --group=0 \
      --caps-retain=CAP_IPC_LOCK \
      --net=host \
      --dns=host \
      --exec=/bin/vault -- \
        server \
        -config=/vault/config/config.json
    ExecStop=-/usr/bin/rkt stop --uuid-file="/var/cache/vault-service.uuid"
    Restart=always
    RestartSec=5
    [Install]
    WantedBy=multi-user.target
  EOT
}

data "ignition_file" "node_ca" {
  filesystem = "root"
  path       = "/etc/vault/node-ca.cert"
  mode       = 256 ### 0400
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = tls_self_signed_cert.ca.cert_pem
  }
}

data "ignition_file" "node_key" {
  count = var.cluster_count

  filesystem = "root"
  path       = "/etc/vault/node.key"
  mode       = 256 ### 0400
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = tls_private_key.node[count.index].private_key_pem
  }
}

data "ignition_file" "node_cert" {
  count = var.cluster_count

  filesystem = "root"
  path       = "/etc/vault/node.cert"
  mode       = 256 ### 0400
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = tls_locally_signed_cert.node[count.index].cert_pem
  }
}

data "ignition_config" "node" {
  count = var.cluster_count

  users = [
    data.ignition_user.core.rendered,
    local.ca_ssh_public_keys ? data.ignition_user.admin[0].rendered : "",
  ]
  files = [
    var.cluster_count > 1 ? data.ignition_file.helper[0].rendered : "",
    local.ca_ssh_public_keys ? data.ignition_file.sshd_config[0].rendered : "",
    local.ca_ssh_public_keys ? data.ignition_file.auth_principals_core[0].rendered : "",
    local.ca_ssh_public_keys ? data.ignition_file.auth_principals_admin[0].rendered : "",
    local.ca_ssh_public_keys ? data.ignition_file.ca_ssh_public_keys[0].rendered : "",
    local.ca_tls_public_keys ? data.ignition_file.ca_tls_public_keys[0].rendered : "",
    data.ignition_file.config[count.index].rendered,
    ### TLS Files
    data.ignition_file.node_ca.rendered,
    data.ignition_file.node_key[count.index].rendered,
    data.ignition_file.node_cert[count.index].rendered,
  ]
  systemd = [
    data.ignition_systemd_unit.service.rendered,
    data.ignition_systemd_unit.mount.rendered,
  ]
  filesystems = [
    data.ignition_filesystem.data.rendered,
  ]
}
