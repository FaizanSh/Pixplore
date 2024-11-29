# modules/ecs_service/main.tf

provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "fastapi_cluster" {
  name = var.cluster_name
}

resource "aws_ecr_repository" "fastapi_repo" {
  name = var.repository_name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "fastapi_task" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "fastapi-container"
      image     = "${aws_ecr_repository.fastapi_repo.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
    }
  ])
}

resource "aws_security_group" "ecs_security_group" {
  name   = "ecs-fastapi-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
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

# Security Group for ALB to allow HTTP access on port 80
resource "aws_security_group" "alb_security_group" {
  name   = "alb-fastapi-sg"
  vpc_id = var.vpc_id

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



# Load balancer
resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "ecs_tg" {
  name     = "ecs-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}


resource "aws_ecs_service" "fastapi_service" {
  name            = "fastapi-service"
  cluster         = aws_ecs_cluster.fastapi_cluster.id
  task_definition = aws_ecs_task_definition.fastapi_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }

  desired_count = var.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "fastapi-container"
    container_port   = 8000
  }
}

##############################################################################

# Listener Rule for Image Analysis Lambda
resource "aws_lb_listener_rule" "fastapi_listener_rule" {
  listener_arn = aws_lb_listener.ecs_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }

  condition {
    path_pattern {
      values = ["/fastapi/*"]
    }
  }
}


# Listener Rule for Landing Page Lambda
resource "aws_lb_listener_rule" "landing_page_rule" {
  listener_arn = aws_lb_listener.ecs_listener.arn
  condition {
    path_pattern {
      values = ["/landing*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = var.landing_page_lambda_target_group_arn
  }
  }

# Listener Rule for Upload Photo Lambda
resource "aws_lb_listener_rule" "upload_photo_rule" {
  listener_arn = aws_lb_listener.ecs_listener.arn
  condition {
    path_pattern {
      values = ["/upload-photo*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = var.upload_photo_lambda_target_group_arn
  }
  }