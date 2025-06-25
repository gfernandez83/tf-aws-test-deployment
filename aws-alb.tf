resource "aws_lb" "ecs-alb" {
  name               = "tf-aws-test-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name      = "TF-AWS-Test-ECS-ALB"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "ecs_alb_sg" {
  name        = "tf-aws-test-ecs-alb-sg"
  description = "Security group for ECS ALB"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "ecs_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP traffic to ECS ALB"
}

resource "aws_security_group_rule" "ecs_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS traffic to ECS ALB"
}

resource "aws_lb_listener" "ecs_http_listener" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    }
}

resource "aws_lb_listener" "ecs_https_listener" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.nginx-domain.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

resource "aws_lb_target_group" "nginx_tg" {
  name        = "tf-aws-test-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }

  tags = {
    Name      = "TF-AWS-Test-ECS-TG"
    ManagedBy = "Terraform"
  }
}
