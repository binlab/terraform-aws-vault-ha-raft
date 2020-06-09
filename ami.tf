data aws_ami "coreos" {
  count = var.ami_image != "" ? 0 : 1

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

data aws_ami "flatcar" {
  count = var.ami_image != "" ? 0 : 1

  most_recent = true
  owners      = ["075585003325"]

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
