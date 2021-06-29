resource aws_lb "cluster" {
  name               = format(local.name_tmpl, "alb")
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.vpc.id,
    aws_security_group.alb.id
  ]

  dynamic "subnet_mapping" {
    for_each = [for value in aws_subnet.public : value.id]
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "alb")
  })
}

resource aws_lb_listener "cluster" {
  load_balancer_arn = aws_lb.cluster.arn
  port              = var.cluster_port
  protocol          = var.certificate_arn != "" ? "HTTPS" : "HTTP"
  ssl_policy        = var.certificate_arn != "" ? "ELBSecurityPolicy-2016-08" : ""
  certificate_arn   = var.certificate_arn != "" ? var.certificate_arn : ""

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cluster.arn
  }
}

resource aws_lb_target_group "cluster" {
  name        = format(local.name_tmpl, "group")
  port        = var.node_port
  target_type = "instance"
  protocol    = "HTTPS"
  vpc_id      = local.vpc_id

  health_check {
    protocol            = "HTTPS"
    path                = "/v1/sys/health"
    port                = var.node_port
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 5
    timeout             = 2
  }
}

resource aws_lb_target_group_attachment "cluster" {
  count = length(aws_instance.node)

  target_group_arn = aws_lb_target_group.cluster.arn
  target_id        = aws_instance.node[count.index].id
  port             = var.node_port
}
