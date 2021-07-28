########################################################################
#                     ALB Security Group and Rules                     #
########################################################################

resource "aws_security_group" "alb" {
  name        = format(local.name_tmpl, "alb")
  description = "Vault HA Cluster ALB"
  vpc_id      = local.vpc_id

  tags = merge(local.tags, {
    Description = "Vault HA Cluster ALB"
    Name        = format(local.name_tmpl, "alb")
  })
}

resource "aws_security_group_rule" "alb_ingress_allow_clients" {
  description       = "Allow Clients Inbound Traffic from Public"
  type              = "ingress"
  from_port         = var.cluster_port
  to_port           = var.cluster_port
  protocol          = "tcp"
  cidr_blocks       = var.cluster_allowed_subnets
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_allow_nodes" {
  description              = "Allow Nodes Inbound Traffic from Cluster"
  type                     = "ingress"
  from_port                = var.cluster_port
  to_port                  = var.cluster_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_allow_nodes" {
  description              = "Allow Health Check Outbound Traffic to Nodes"
  type                     = "egress"
  from_port                = var.node_port
  to_port                  = var.node_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.alb.id
}

########################################################################
#                     Node Security Group and Rules                    #
########################################################################

resource "aws_security_group" "node" {
  name        = format(local.name_tmpl, "node")
  description = "Vault HA Cluster Node"
  vpc_id      = local.vpc_id

  tags = merge(local.tags, {
    Description = "Vault HA Cluster Node"
    Name        = format(local.name_tmpl, "node")
  })
}

resource "aws_security_group_rule" "node_ingress_allow_alb" {
  description              = "Allow Health Check Inbound Traffic from ALB"
  type                     = "ingress"
  from_port                = var.node_port
  to_port                  = var.node_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_ingress_allow_peer" {
  for_each = { for i, value in [var.node_port, var.peer_port] : i => value }

  description       = "Allow Peer Inbound Traffic from Self SG"
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_ingress_allow_ssh" {
  description       = "Allow SSH Inbound Traffic from Self SG"
  type              = "ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_egress_allow_all" {
  description       = "Allow All Outbound Traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_ingress_allow_public_http" {
  count = var.node_allow_public ? 1 : 0

  description       = "Allow Public HTTP Inbound Traffic to Nodes"
  type              = "ingress"
  from_port         = var.node_port
  to_port           = var.node_port
  protocol          = "tcp"
  cidr_blocks       = var.node_allowed_subnets
  security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_ingress_allow_public_ssh" {
  count = var.node_allow_public ? 1 : 0

  description       = "Allow Public SSH Inbound Traffic to Nodes"
  type              = "ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  cidr_blocks       = var.ssh_allowed_subnets
  security_group_id = aws_security_group.node.id
}
