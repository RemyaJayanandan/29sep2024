output "autoscaling_group_id" {
  value = aws_autoscaling_group.ec2_asg.id
}

output "launch_template_id" {
  value = aws_launch_template.ec2_launch_template.id
}
