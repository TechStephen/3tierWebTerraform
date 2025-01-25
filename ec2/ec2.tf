
resource "aws_instance" "private_instance_1" {
  ami = "ami-063d43db0594b521b"  # Check if this is correct for your region and architecture
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key_pair.key_name
  subnet_id = var.subnet_ids[0]  # Ensure you're using .id, not .vpc_id
  security_groups = [aws_security_group.private_sg.id]
  

  tags = {
    Name = "PrivateSubnet1FE"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -g npm
    sudo yum install -g pm2@latest
  EOF

  # dont destory and rebuild when changes are made to this resource (still applies changes)
  # lifecycle {
  #  ignore_changes = [aws_security_group]
  #}
}

resource "aws_instance" "private_instance_2" {
  ami = "ami-063d43db0594b521b"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key_pair_two.key_name
  subnet_id = var.subnet_ids[1]  # Ensure you're using .id, not .vpc_id
  security_groups = [aws_security_group.private_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -g npm
    sudo yum install -g pm2@latest
  EOF

  tags = {
    Name = "PrivateSubnet2FE"
  }
}

resource "aws_instance" "private_instance_3" {
  ami = "ami-063d43db0594b521b"  # Check if this is correct for your region and architecture
  instance_type = "t2.micro"
  subnet_id = var.subnet_ids[2]  # Ensure you're using .id, not .vpc_id
  security_groups = [aws_security_group.private_sg.id]

  iam_instance_profile = var.instance_profile_id # For dynamodb access

  tags = {
    Name = "PrivateSubnet1BE"
  }
}

resource "aws_instance" "private_instance_4" {
  ami = "ami-063d43db0594b521b"
  instance_type = "t2.micro"
  subnet_id = var.subnet_ids[3]  # Ensure you're using .id, not .vpc_id
  security_groups = [aws_security_group.private_sg.id]

  iam_instance_profile = var.instance_profile_id

  tags = {
    Name = "PrivateSubnet2BE"
  }
}

resource "aws_eip" "eip_one" {
  instance = aws_instance.private_instance_1.id
}

resource "aws_eip" "eip_two" {
  instance = aws_instance.private_instance_2.id
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
