module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name             = format(local.name_tmpl, "vpc")
  default_vpc_name = format(local.name_tmpl, "vpc")
  cidr             = var.vpc_cidr
  azs              = data.aws_availability_zones.current.names
  private_subnets = (var.vpc_private_subnets != []
    ? var.vpc_private_subnets
    : formatlist(
      var.vpc_private_subnet_tmpl,
      range(1, length(data.aws_availability_zones.current.names) + 1)
    )
  )
  public_subnets = (var.vpc_public_subnets != []
    ? var.vpc_public_subnets
    : formatlist(
      var.vpc_public_subnet_tmpl,
      range(1, length(data.aws_availability_zones.current.names) + 1)
    )
  )
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = merge(local.tags, {
    Name = format(local.name_tmpl, "public")
  })

  public_route_table_tags = merge(local.tags, {
    Name = format(local.name_tmpl, "public")
  })

  private_subnet_tags = merge(local.tags, {
    Name = format(local.name_tmpl, "private")
  })

  private_route_table_tags = merge(local.tags, {
    Name = format(local.name_tmpl, "private")
  })

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "vpc")
  })

  vpc_tags = merge(local.tags, {
    Name = format(local.name_tmpl, "vpc")
  })

  igw_tags = merge(local.tags, {
    Name = format(local.name_tmpl, "igw")
  })

  default_vpc_tags = merge(local.tags, {
    Name = format(local.name_tmpl, "vpc")
  })
}

