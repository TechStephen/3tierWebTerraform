# Public Security Group (For Load Balancer - ALB)
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow inbound and outbound traffic for Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "PublicSecurityGroup"
  }

  # Allow inbound HTTP (80) from anywhere (for ALB)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from anywhere"
  }

  # Allow inbound HTTPS (443) from anywhere (if HTTPS is used)
  #ingress {
  #  from_port   = 443
  #  to_port     = 443
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
  #  description = "Allow HTTPS traffic from anywhere"
  #}

  # Allow outbound traffic to EC2 instances (BE)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# Private Security Group (For EC2 instances in ASG)
resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Allow ALB to communicate with EC2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "PrivateSecurityGroup"
  }

  # Allow inbound HTTP from ALB only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]  # Only allow ALB to send traffic
    description     = "Allow HTTP traffic from ALB"
  }

  # Allow EC2 instances to access DynamoDB (Dynamodb uses 443, is not strictly for HTTP)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # AWS DynamoDB is a global service
    description = "Allow EC2 instances to access DynamoDB"
  }

  # Allow outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic (via NAT if private)"
  }
}
