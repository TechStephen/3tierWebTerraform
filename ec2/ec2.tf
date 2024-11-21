# create ec2
resource "aws_instance" "public_instance_1" {
  ami = "ami-063d43db0594b521b"  # Check if this is correct for your region and architecture
  instance_type = "t2.micro"
  subnet_id = var.public_subnet_id_1  # Ensure you're using .id, not .vpc_id
  security_groups = [aws_security_group.public_sg.id]

  tags = {
    Name = "PublicSubnet1"
  }

  # dont destory and rebuild when changes are made to this resource (still applies changes)
  # lifecycle {
  #  ignore_changes = [aws_security_group]
  #}
}

resource "aws_instance" "public_instance_2" {
  ami = "ami-063d43db0594b521b"
  instance_type = "t2.micro"
  subnet_id = var.public_subnet_id_2  # Ensure you're using .id, not .vpc_id
  security_groups = [aws_security_group.public_sg.id]

  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_instance" "private_instance_1" {
  ami = "ami-063d43db0594b521b"  # Check if this is correct for your region and architecture
  instance_type = "t2.micro"
  subnet_id = var.private_subnet_id_1  # Ensure you're using .id, not .vpc_id
  security_groups = [aws_security_group.public_sg.id]

  iam_instance_profile = var.instance_profile_id

  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_instance" "private_instance_2" {
  ami = "ami-063d43db0594b521b"
  instance_type = "t2.micro"
  subnet_id = var.private_subnet_id_2  # Ensure you're using .id, not .vpc_id
  security_groups = [aws_security_group.public_sg.id]

  iam_instance_profile = var.instance_profile_id

  tags = {
    Name = "PrivateSubnet2"
  }
}
