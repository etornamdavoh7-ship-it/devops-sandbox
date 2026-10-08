resource "aws_ecs_task_definition" "frontend" {
  family                   = "devops-sandbox-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "react-frontend-container"
      image     = "${aws_ecr_repository.frontend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "PORT", value = "80" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ui"
        }
      }
    }
  ])

}


resource "aws_ecs_service" "frontend" {
  name            = "devops-sandbox-frontend"
  cluster         = aws_ecs_cluster.devops_sandbox_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.frontend.arn
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
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "react-frontend-container"
    container_port   = 80
  }
}