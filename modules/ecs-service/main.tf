# IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Attach execution policy to the role
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM role for ECS tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container",
      image     = var.container_image,
      essential = true,
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.container_port,
          protocol      = "tcp"
        }
      ],
      environment = var.container_environment,
      command = [
        "/bin/sh",
        "-c",
        <<-EOF
        cat > /usr/share/nginx/html/index.html << ENDHTML
        <!DOCTYPE html>
        <html>
        <head>
            <title>Sonar POC</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    margin: 40px;
                    text-align: center;
                }
                h1 {
                    color: #333;
                }
            </style>
        </head>
        <body>
            <h1>Hello world!</h1>
        </body>
        </html>
        ENDHTML
        nginx -g 'daemon off;'
        EOF
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

# CloudWatch Log Group for container logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# ECS Service
resource "aws_ecs_service" "app" {
  name                               = "${var.project_name}-service"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.app.arn
  launch_type                        = "EC2"
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project_name}-container"
    container_port   = var.container_port
  }

  tags = var.tags

  depends_on = [var.lb_listener_arn]
}

# Auto Scaling for ECS Service
resource "aws_appautoscaling_target" "ecs" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.autoscaling_min_capacity
  max_capacity       = var.autoscaling_max_capacity
}

# CPU-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "${var.project_name}-scale-cpu"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
