resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-cluster"
  
  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
  
  tags = var.tags
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${var.project_name}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.project_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "ecs_instances" {
  name        = "${var.project_name}-ecs-instances"
  description = "Security group for ECS instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.alb_security_group_id != "" ? [var.alb_security_group_id] : []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = var.tags
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project_name}-ecs-lt-"
  image_id      = data.aws_ami.ecs.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ecs_instances.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.project_name}-ecs-instance"
    })
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.project_name}-ecs-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnet_ids
  health_check_type   = "EC2"
  force_delete        = true

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name = "${var.project_name}-ecs-instance"
    })
    
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
