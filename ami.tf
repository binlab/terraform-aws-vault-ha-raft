data "aws_ami" "coreos" {
  count = var.ami_image == "" && var.ami_vendor == "coreos" ? 1 : 0

  most_recent = true
  owners      = ["595879546273"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = [
      format("CoreOS-%s-*", var.ami_channel)
    ]
  }
}

data "aws_ami" "flatcar" {
  count = var.ami_image == "" && var.ami_vendor == "flatcar" ? 1 : 0

  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = [
      format("Flatcar-%s-*", var.ami_channel)
    ]
  }
}
