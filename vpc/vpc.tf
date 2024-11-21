# create vpc
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16" # provide cidr block
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      name = "my-vpc"
    }
}

# create public subnet 1 (us-east-1a)
resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
      Name = "PublicSubnet1"
    }
}

# create public subnet 2 (us-east-1b)
resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
      Name = "PublicSubnet2"
    }
}

# create private subnet 1 (us-east-1a)
resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
      Name = "PrivateSubnet1"
    }
}

# create private subnet 2 (us-east-1b)
resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
      Name = "PrivateSubnet2"
    }
}

# Create vpc endpoint to hook up dynamodb
resource "aws_vpc_endpoint" "my_vpc_endpoint" {
  vpc_endpoint_type = "Gateway"
  vpc_id = aws_vpc.my_vpc.id
  service_name = "com.amazonaws.us-east-1.dynamodb" # connects wth dynamodb table associated with my account through this region
  route_table_ids = [aws_route_table.private_route_table.id]
}