# Create a Database RDS Subnet Group and assign to it all subnets

resource "aws_db_subnet_group" "rds" {
  name       = "rds"
  subnet_ids = [for value in aws_subnet.main : value.id]

  tags = {
    Name = "rds"
  }
}

# Create a separate Security Group for RDS instance

resource "aws_security_group" "rds" {
  name   = "rds"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow connections to RDS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds"
  }
}

# Create a Database RDS classic instance

resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "rds"
  name                 = "rds"
  port                 = 3306
  username             = "root"
  password             = "Pa55w0rd"
  skip_final_snapshot  = true
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.rds.id
  availability_zone    = data.aws_availability_zones.current.names[0]

  vpc_security_group_ids = [
    aws_vpc.main.default_security_group_id,
    aws_security_group.rds.id,
  ]
}
