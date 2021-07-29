# Create separate Main VPC network

resource "aws_vpc" "main" {
  cidr_block           = var.main_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

# Create subnets in Main VPC with a count equal to availability zones 

resource "aws_subnet" "main" {
  for_each = toset(data.aws_availability_zones.current.names)

  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone       = each.value

  cidr_block = cidrsubnet(
    var.main_vpc_subnet_cidr,
    var.main_vpc_subnet_mask - split("/", var.main_vpc_subnet_cidr)[1],
    index(data.aws_availability_zones.current.names, each.key)
  )

  tags = {
    Name = format("main-%s", each.value)
  }
}

# Create and assign Route Table to Main VPC

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block                = var.vault_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vault_main.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "main" {
  for_each = toset(data.aws_availability_zones.current.names)

  subnet_id      = aws_subnet.main[each.value].id
  route_table_id = aws_route_table.main.id
}

# Create a Route in existing Route Table of Vault Cluster

resource "aws_route" "main" {
  route_table_id            = module.vault.route_table
  destination_cidr_block    = var.main_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vault_main.id
}

# Configuring VPC peering connections between different VPCs

resource "aws_vpc_peering_connection" "vault_main" {
  vpc_id      = module.vault.vpc_id
  peer_vpc_id = aws_vpc.main.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "vault-main"
  }
}
