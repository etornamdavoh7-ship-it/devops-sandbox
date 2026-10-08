resource "aws_ecs_task_definition" "backend" {
  family                   = "devops-sandbox-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend-api-container"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "PORT", value = "5000" },
        { name = "ALLOWED_ORIGINS", value = "http://${aws_lb.devops_sandbox_alb.dns_name}" }
      ]

      secrets = [
        { name = "MONGO_URI", valueFrom = aws_ssm_parameter.mongo_uri.arn }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "api"
        }
      }
    }
  ])

}


resource "aws_ecs_service" "backend" {
  name            = "devops-sandbox-backend"
  cluster         = aws_ecs_cluster.devops_sandbox_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1

  network_configuration {
    subnets = [
      aws_subnet.sandbox_private_subnet_1a.id,
      aws_subnet.sandbox_private_subnet_1b.id
    ]
    security_groups  = [aws_security_group.devops_sandbox_app_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend-api-container"
    container_port   = 5000
  }
}