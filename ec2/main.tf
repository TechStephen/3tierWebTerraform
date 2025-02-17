
resource "aws_instance" "public_instance_1" {
  ami = "ami-063d43db0594b521b"  # Check if this is correct for your region and architecture
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key_pair.key_name
  subnet_id = var.subnet_ids[0]  # Ensure you're using .id, not .vpc_id
  security_groups = [var.public_security_group_id]

  tags = {
    Name = "PublicSubnet1FE"
  }

  # Install dependancies and cloud watch agent with config in SSM Parameter Store
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -g npm
    sudo yum install -g pm2@latest

    sudo yum install -y amazon-cloudwatch-agent
    sudo systemctl enable amazon-cloudwatch-agent
    sudo systemctl start amazon-cloudwatch-agent

    sudo amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/AmazonCloudWatch-linux
  EOF

  # dont destory and rebuild when changes are made to this resource (still applies changes)
  # lifecycle {
  #  ignore_changes = [aws_security_group]
  #}
}

resource "aws_instance" "public_instance_2" {
  ami = "ami-063d43db0594b521b"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key_pair_two.key_name
  subnet_id = var.subnet_ids[1]  # Ensure you're using .id, not .vpc_id
  security_groups = [var.public_security_group_id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -g npm
    sudo yum install -g pm2@latest

    sudo yum install -y amazon-cloudwatch-agent
    sudo systemctl enable amazon-cloudwatch-agent
    sudo systemctl start amazon-cloudwatch-agent

    sudo amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/AmazonCloudWatch-linux
  EOF

  tags = {
    Name = "PublicSubnet2FE"
  }
}

resource "aws_instance" "private_instance_1" {
  ami = "ami-063d43db0594b521b"  # Check if this is correct for your region and architecture
  instance_type = "t2.micro"
  subnet_id = var.subnet_ids[2]  # Ensure you're using .id, not .vpc_id
  security_groups = [var.private_security_group_id]

  iam_instance_profile = var.instance_profile_id # For dynamodb access

  tags = {
    Name = "PrivateSubnet1BE"
  }
}

resource "aws_instance" "private_instance_2" {
  ami = "ami-063d43db0594b521b"
  instance_type = "t2.micro"
  subnet_id = var.subnet_ids[3]  # Ensure you're using .id, not .vpc_id
  security_groups = [var.private_security_group_id]

  iam_instance_profile = var.instance_profile_id

  tags = {
    Name = "PrivateSubnet2BE"
  }
}

resource "aws_eip" "eip_one" {
  instance = aws_instance.public_instance_1.id
}

resource "aws_eip" "eip_two" {
  instance = aws_instance.public_instance_2.id
}

resource "aws_ssm_parameter" "cw_log_param" {
  name  = "/AmazonCloudWatch-linux"
  type  = "String"
  value = file("cloudwatch-agent-config.json")
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_key_pair"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "tls_private_key" "my_key_two" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "my_key_pair_two" {
  key_name   = "my_key_pair"
  public_key = tls_private_key.my_key_two.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.my_key_two.private_key_pem
  filename = "./my_key_pair_two.pem"
}

# When scaling in and out what instance type/size do you want to add
resource "aws_launch_template" "asg_launch_template" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.public_security_group_id]
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

# creates load balancer
resource "aws_lb" "app_lb" {
  name = "my-app-lb"
  internal = false # allows load balancer to be accessible to the internet and not private within the vpc
  load_balancer_type = "application"
  security_groups = [var.public_security_group_id]
  subnets = [var.subnet_ids[0], var.subnet_ids[1]]

  enable_deletion_protection = true # prevents accidental deletion when set to true 

  # stops from destroying and rebuilding every apply
  # lifecycle {
  #  prevent_destroy = true
  #}

  tags = {
    Name = "MyApplicationLoadBalancer"
  }
}

# creates target group (knows which instances to balance load to)
resource "aws_lb_target_group" "lb_tg" {
    name = "app-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
    
    health_check { # neccesary for not load balancing on an unhealthy instance
      port = "traffic-port" # uses target groups port
      path = "/" # home page
      interval = "30" # try every 30 seconds
      timeout = "5" # how long the lb waits for a response
      healthy_threshold = "2" # if succesful twice stop and declare healthy 
      unhealthy_threshold = "2" # if unsuccesful twice stop and declare unhealthy
    }
}

# attaches ec2 to target group 
resource "aws_lb_target_group_attachment" "attach_first_instance" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id = aws_instance.public_instance_1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "attach_second_instance" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id = aws_instance.public_instance_2.id
  port = 80
}


# creates listener for HTTP traffic 
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward" # should forward to target group 
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}