# Create separate VPC network

resource aws_vpc "rds" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "rds"
  }
}

# Create subnets in VPC with a count equal to availability zones 

resource aws_subnet "rds" {
  count = length(data.aws_availability_zones.rds.names)

  vpc_id                  = aws_vpc.rds.id
  cidr_block              = format("10.0.%d.0/24", count.index + 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.rds.names[count.index]

  tags = {
    Name = format("rds-%s", data.aws_availability_zones.rds.names[count.index])
  }
}

# Create and assign Route Table to RDS VPC

resource aws_route_table "rds" {
  vpc_id = aws_vpc.rds.id

  route {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vault_rds.id
  }

  tags = {
    Name = "rds"
  }
}

resource aws_route_table_association "rds" {
  count = length(aws_subnet.rds)

  subnet_id      = aws_subnet.rds[count.index].id
  route_table_id = aws_route_table.rds.id
}

# Create a Route in existing Route Table of Vault Cluster

resource aws_route "rds" {
  route_table_id            = module.vault.route_table
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.vault_rds.id
}

# Configuring VPC peering connections between different VPCs

resource aws_vpc_peering_connection "vault_rds" {
  vpc_id      = module.vault.vpc_id
  peer_vpc_id = aws_vpc.rds.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "vault-rds"
  }
}
