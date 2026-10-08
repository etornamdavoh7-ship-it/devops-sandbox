resource "aws_security_group" "devops_sandbox_alb_sg" {
  name        = "devops-sandbox-alb-sg"
  description = "Security group for the ALB, allowing inbound HTTP traffic and outbound traffic to the internet"
  vpc_id      = aws_vpc.devops_sandbox_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "devops_sandbox_app_sg" {
  name        = "devops-sandbox-app-sg"
  description = "Security group for the application instances"
  vpc_id      = aws_vpc.devops_sandbox_vpc.id

  ingress {
    description     = "React Frontend"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.devops_sandbox_alb_sg.id]
  }

  ingress {
    description     = "Node Backend"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.devops_sandbox_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "devops_sandbox_db_sg" {
  name        = "devops-sandbox-db-sg"
  description = "Security group for the database instance"
  vpc_id      = aws_vpc.devops_sandbox_vpc.id

  ingress {
    description     = "MongoDB"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.devops_sandbox_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}