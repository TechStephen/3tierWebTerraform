# creates load balancer
resource "aws_lb" "app_lb" {
  name = "my-app-lb"
  internal = false # allows load balancer to be accessible to the internet and not private within the vpc
  load_balancer_type = "application"
  security_groups = [aws_security_group.public_sg.id]
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