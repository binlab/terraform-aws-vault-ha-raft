resource aws_security_group "vpc" {
  name        = format(local.name_tmpl, "vpc")
  description = "Internal VPC Traffic"
  vpc_id      = aws_vpc.this.id

  tags = merge(local.tags, {
    Description = "Internal VPC Traffic"
    Name        = format(local.name_tmpl, "vpc")
  })
}

resource aws_security_group "alb" {
  name        = format(local.name_tmpl, "alb")
  description = "Allow Public Inbound Traffic to ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow Public Clients Connection to Vault"
    from_port   = var.cluster_port
    to_port     = var.cluster_port
    protocol    = "tcp"
    cidr_blocks = var.cluster_allowed_subnets
  }

  ingress {
    description     = "Allow Inbound Traffic from Nodes"
    from_port       = var.cluster_port
    to_port         = var.cluster_port
    protocol        = "tcp"
    cidr_blocks     = []
    security_groups = [aws_security_group.vpc.id]
  }

  egress {
    from_port       = var.node_port
    to_port         = var.node_port
    protocol        = "tcp"
    cidr_blocks     = []
    security_groups = [aws_security_group.vpc.id]
  }

  tags = merge(local.tags, {
    Description = "Allow Public Inbound Traffic to ALB"
    Name        = format(local.name_tmpl, "alb")
  })
}

resource aws_security_group "node" {
  name        = format(local.name_tmpl, "node")
  description = "Allow ALB Inbound Traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow Health Check from ALB"
    from_port       = var.node_port
    to_port         = var.node_port
    protocol        = "tcp"
    cidr_blocks     = []
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Allow Cluster Inbound Traffic"
    from_port       = var.node_port
    to_port         = var.peer_port
    protocol        = "tcp"
    cidr_blocks     = []
    security_groups = [aws_security_group.vpc.id]
  }

  ingress {
    description     = "Allow SSH Connection from self VPC Security Group"
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    cidr_blocks     = []
    security_groups = [aws_security_group.vpc.id]
  }

  egress {
    description = "Allow All Outbound Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Description = "Allow ALB Inbound Traffic"
    Name        = format(local.name_tmpl, "node")
  })
}

resource aws_security_group "public" {
  count = var.node_allow_public ? 1 : 0

  name        = format(local.name_tmpl, "public")
  description = "Allow EC2 Instacies Public"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow Public HTTP Connection to Vault on EC2"
    from_port   = var.node_port
    to_port     = var.node_port
    protocol    = "tcp"
    cidr_blocks = var.node_allowed_subnets
  }

  ingress {
    description = "Allow Public SSH Connection to Vault on EC2"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_subnets
  }

  tags = merge(local.tags, {
    Description = "Allow EC2 Instacies Public"
    Name        = format(local.name_tmpl, "public")
  })
}
