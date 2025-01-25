# Security group that allows inbound and outbound traffic
resource "aws_security_group" "public_sg" {
  name = "public_sg"
  description = "Allow inbound and outbound traffic"
  vpc_id = var.vpc_id

  tags = {
    Name = "PublicSecurityGroup"
  }

  # inbound traffic (allow all http, tcp helps secure connection)
  # For HTTPS (443) needs certificate (AWS Certificate Manager)
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound traffic (allow all ssh, tcp helps secure connection)
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # limit in production
  }

  # outbound traffic (allow all)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name = "public_sg"
  description = "Allow fe and be to communicate with each other traffic"
  vpc_id = var.vpc_id

  tags = {
    Name = "PublicSecurityGroup"
  }

  # Inbound HTTP for communication between FE and BE within the same SG
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.private_sg.id]  # Allow communication within the same security group
  }

  # outbound traffic (allow all)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}