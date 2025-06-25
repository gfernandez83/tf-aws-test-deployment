resource "aws_ecs_cluster" "nginx_cluster" {
    name = "nginx-cluster"
    tags = {
        Name = "nginx-cluster"
        ManagedBy = "Terraform"
    }
}

resource "aws_ecs_task_definition" "nginx" {
    execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
    family            = "nginx-task"
    network_mode      = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu               = "256"
    memory            = "512"
    container_definitions = jsonencode([
        {
            name = "nginx-container"
            image = "nginx:latest"
            portMappings = [
                {
                    containerPort = 80
                    protocol = "tcp"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group"         = "/ecs/nginx"
                    "awslogs-region"        = data.aws_region.current.region
                    "awslogs-stream-prefix" = "nginx"
                }
            }
        }
    ])
    tags = {
        Name = "nginx-task-definition"
        ManagedBy = "Terraform"
    }
}

resource "aws_security_group" "nginx_sg" {
    name        = "nginx-sg"
    description = "Security group for Nginx ECS service"
    vpc_id      = module.vpc.vpc_id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "nginx_http" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    security_group_id = aws_security_group.nginx_sg.id
    source_security_group_id = aws_security_group.ecs_alb_sg.id
}

resource "aws_ecs_service" "nginx_service" {
    name            = "nginx-service"
    cluster         = aws_ecs_cluster.nginx_cluster.id
    task_definition = aws_ecs_task_definition.nginx.arn
    desired_count   = 1
    launch_type     = "FARGATE"

    network_configuration {
        subnets          = module.vpc.private_subnets
        security_groups  = [aws_security_group.nginx_sg.id]
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.nginx_tg.arn
        container_name   = "nginx-container"
        container_port   = 80
    }

    tags = {
        Name      = "nginx-service"
        ManagedBy = "Terraform"
    }
}