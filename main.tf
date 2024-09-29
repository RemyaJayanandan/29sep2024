provider "aws" {
  region = var.aws_region
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# Launch Template for EC2 Instance
resource "aws_launch_template" "ec2_launch_template" {
  name          = "ec2-launch-template"
  image_id      = "ami-0522ab6e1ddcc7055"  # Choose AMI suitable for your region
  instance_type = "t2.micro"
  key_name      = var.key_name

# Base64 encode the user_data script
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Hello, World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
              )
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ec2_asg" {
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [var.subnet_id]
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1

  tag {
    key                 = "Name"
    value               = "autoscaling-instance"
    propagate_at_launch = true
  }
}

# CloudWatch Alarms for Scaling
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale_up_on_high_cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "scale_down_on_low_cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg.name
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = aws_autoscaling_group.ec2_asg.name
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = aws_autoscaling_group.ec2_asg.name
}
