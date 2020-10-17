locals {
  public_subnets_list = (var.vpc_public_subnets != []
    ? var.vpc_public_subnets
    : formatlist(
      var.vpc_public_subnet_tmpl,
      range(1, length(data.aws_availability_zones.current.names) + 1)
    )
  )
  private_subnets_list = (var.vpc_private_subnets != []
    ? var.vpc_private_subnets
    : formatlist(
      var.vpc_private_subnet_tmpl,
      range(1, length(data.aws_availability_zones.current.names) + 1)
    )
  )
  vpc_public_subnets = ({
    for key, value in local.public_subnets_list
    : key => {
      zone_name  = element(data.aws_availability_zones.current.names, key)
      zone_id    = element(data.aws_availability_zones.current.zone_ids, key)
      cidr_block = value
    }
  })
  vpc_private_subnets = ({
    for key, value in local.private_subnets_list
    : key => {
      zone_name  = element(data.aws_availability_zones.current.names, key)
      zone_id    = element(data.aws_availability_zones.current.zone_ids, key)
      cidr_block = value
    }
  })
}

########################################################################
#                              Cluster VPC                             #
########################################################################

resource aws_vpc "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "cluster")
  })
}

########################################################################
#                             Public Subnet                            #
########################################################################

resource aws_subnet "public" {
  for_each = local.vpc_public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.zone_name
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = format(local.name_tmpl,
      format(
        "public-%s",
        regex("^[a-z]+-[a-z]+-\\d([a-z])$", each.value.zone_name)[0]
      )
    )
  })
}

resource aws_route_table "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "public")
  })
}

resource aws_route_table_association "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource aws_internet_gateway "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "public")
  })
}

resource aws_route "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.public.id
  destination_cidr_block = "0.0.0.0/0"
}

########################################################################
#                            Private Subnet                            #
########################################################################

resource aws_subnet "private" {
  for_each = local.vpc_private_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.zone_name
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = format(local.name_tmpl,
      format(
        "private-%s",
        regex("^[a-z]+-[a-z]+-\\d([a-z])$", each.value.zone_name)[0]
      )
    )
  })
}

resource aws_route_table "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "private")
  })
}

resource aws_route_table_association "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

########################################################################
#                              NAT Gataway                             #
########################################################################

resource aws_eip "nat" {
  count = var.nat_enabled ? 1 : 0

  vpc = true

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "nat")
  })
}

resource aws_nat_gateway "private" {
  count = var.nat_enabled ? 1 : 0

  allocation_id = element(aws_eip.nat, 0).id
  subnet_id     = element([for value in aws_subnet.public : value.id], 0)

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "private")
  })
}

resource aws_route "private" {
  count = var.nat_enabled ? 1 : 0

  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = element(aws_nat_gateway.private, 0).id
  destination_cidr_block = "0.0.0.0/0"
}
