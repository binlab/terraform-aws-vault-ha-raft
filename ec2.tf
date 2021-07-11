resource "aws_instance" "node" {
  count = var.cluster_count

  instance_type        = var.node_instance_type
  monitoring           = var.node_monitoring
  availability_zone    = element(data.aws_availability_zones.current.names, count.index)
  user_data            = data.ignition_config.node[count.index].rendered
  iam_instance_profile = var.autounseal ? aws_iam_instance_profile.autounseal[0].id : ""

  ami = (
    var.ami_image != "" ? var.ami_image : (
      var.ami_vendor == "flatcar"
      ? data.aws_ami.flatcar[0].image_id
      : data.aws_ami.coreos[0].image_id
    )
  )

  subnet_id = (
    var.node_allow_public
    ? element([for value in aws_subnet.public : value.id], count.index)
    : element([for value in aws_subnet.private : value.id], count.index)
  )

  vpc_security_group_ids = compact([
    aws_security_group.vpc.id,
    aws_security_group.node.id,
    var.node_allow_public ? aws_security_group.public[0].id : "",
  ])

  tags = merge(local.tags, {
    Name    = format(local.name_tmpl, format("node%d", count.index))
    Version = var.docker_tag
  })

  volume_tags = merge(local.tags, {
    Name = format(local.name_tmpl, format("node%d", count.index))
  })

  credit_specification {
    cpu_credits = var.node_cpu_credits
  }

  lifecycle {
    ignore_changes = [
      ami,
      # Added due: 
      # https://github.com/terraform-providers/terraform-provider-aws/issues/729
      volume_tags,
    ]
  }

  root_block_device {
    volume_size           = var.node_volume_size
    volume_type           = var.node_volume_type
    delete_on_termination = true
  }

  depends_on = [
    aws_subnet.public,
    aws_subnet.private,
  ]
}

resource "aws_ebs_volume" "data" {
  count = var.cluster_count

  availability_zone = element(data.aws_availability_zones.current.names, count.index)
  size              = var.data_volume_size
  type              = var.data_volume_type

  tags = merge(local.tags, {
    Name     = format(local.name_tmpl, format("raft%d", count.index))
    Snapshot = true
  })
}

resource "aws_volume_attachment" "node" {
  count = var.cluster_count

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.data[count.index].id
  instance_id = aws_instance.node[count.index].id

  depends_on = [aws_instance.node]
}
