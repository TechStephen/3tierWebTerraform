# When scaling in and out what instance type/size do you want to add
resource "aws_launch_template" "asg_launch_template" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  image_id = "ami-063d43db0594b521b"
}

# create auto scaling group
resource "aws_autoscaling_group" "app_asg" {
  name = "app-asg"

  # When scaling in and out what instance size do you want to add
  launch_template {
    id = aws_launch_template.asg_launch_template.id
    version = "$Latest" 
  }

  target_group_arns = [aws_lb_target_group.lb_tg.arn]
  vpc_zone_identifier = [var.subnet_ids[0], var.subnet_ids[1]] 

  desired_capacity = 2
  max_size = 4
  min_size = 2

  # health_check_type = "ec2"
  # health_check_grace_period = 300
}

# Scale in policy 
resource "aws_autoscaling_policy" "scale_in" {
  name = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  scaling_adjustment = 1 # adds one ec2 instance
  cooldown = 300
  adjustment_type = "ChangeInCapacity"
}

# Scale out policy 
resource "aws_autoscaling_policy" "scale_out" {
  name = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  scaling_adjustment = -1 # removes one ec2 instance
  cooldown = 300
  adjustment_type = "ChangeInCapacity"
}