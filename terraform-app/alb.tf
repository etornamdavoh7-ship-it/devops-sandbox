resource "aws_lb" "devops_sandbox_alb" {
  name               = "devops-sandbox-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.devops_sandbox_alb_sg.id]
  subnets = [
    aws_subnet.sandbox_public_subnet_1a.id,
    aws_subnet.sandbox_public_subnet_1b.id
  ]
}

resource "aws_lb_target_group" "frontend" {
  name        = "devops-sandbox-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.devops_sandbox_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "backend" {
  name        = "devops-sandbox-backend-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.devops_sandbox_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.devops_sandbox_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.frontend.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "api_routing" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    target_group_arn = aws_lb_target_group.backend.arn
    type             = "forward"
  }
}