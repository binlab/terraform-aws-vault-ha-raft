###########################################################################
#                           SSH Authorized Key                            #
###########################################################################

resource "tls_private_key" "core" {
  count = local.ssh_authorized_keys ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

###########################################################################
#                              Root CA Cert                               #
###########################################################################

resource tls_private_key "ca" {
  algorithm   = "RSA"
  rsa_bits    = 2048

  lifecycle {
    prevent_destroy = false
  }
}

resource tls_self_signed_cert "ca" {
  key_algorithm      = "RSA"
  private_key_pem    = tls_private_key.ca.private_key_pem
  is_ca_certificate  = true
  set_subject_key_id = true

  subject {
    common_name         = format("%s Root CA", var.cluster_description)
    organizational_unit = format("%s Certification Authority", var.cluster_description)
    organization        = var.cluster_description
  }

  validity_period_hours = 87600 ### hours == 315360000sec

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]

  lifecycle {
    prevent_destroy = false
  }
}

###########################################################################
#                                Node Cert                                #
###########################################################################

resource tls_private_key "node" {
  count = var.cluster_count

  algorithm   = "RSA"
  rsa_bits    = 2048
  ecdsa_curve = "P256"

  lifecycle {
    prevent_destroy = false
  }
}

resource tls_cert_request "node" {
  count = var.cluster_count

  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.node[count.index].private_key_pem

  subject {
    common_name         = format(local.internal_domain_tmpl, count.index)
    organizational_unit = format("%s Certificate", var.cluster_description)
    organization        = var.cluster_description
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource tls_locally_signed_cert "node" {
  count = var.cluster_count

  cert_request_pem   = tls_cert_request.node[count.index].cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.node_cert_hours_valid

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}
