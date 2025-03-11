# Creates vpc
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16" # provide cidr block
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      name = "my-vpc"
    }
}

# Creates public subnet 1 for load balancer (us-east-1a)
resource "aws_subnet" "lb_public_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
      Name = "LoadBalancerPublicSubnet1"
    }
}

# Creates public subnet 2 for load balancer (us-east-1b)
resource "aws_subnet" "lb_public_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
      Name = "LoadBalancerPublicSubnet2"
    }
}

# Creates private subnet 1 for ec2  (us-east-1a)
resource "aws_subnet" "ec2_private_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
      Name = "EC2PrivateSubnet1"
    }
}

# Creates private subnet 2 for ec2 (us-east-1b)
resource "aws_subnet" "ec2_private_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
      Name = "EC2PrivateSubnet2"
    }
}

# Creates internet gateway
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "MyInternetGateway"
    }
}

# Creates route table (needed to connect to igw)
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "PublicRouteTable"
    }
}

# Creates route connect subnet to internet gateway
resource "aws_route" "public_internet_route" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id = aws_route_table.public_route_table.id
    gateway_id = aws_internet_gateway.my_igw.id
}

# Connect Load Balancer Public Subnet 1 to Route Table
resource "aws_route_table_association" "lb_public_subnet_association_1" {
  subnet_id = aws_subnet.lb_public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Connect Load Balancer Public Subnet 2 to Route Table
resource "aws_route_table_association" "lb_public_subnet_association_2" {
  subnet_id = aws_subnet.lb_public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Creates Private Route Table (For DynamoDB, AWS will automatically configure route)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "PrivateRouteTable"
  }
}

# Connect EC2 Private Subnet 1 to Private Route Table 
resource "aws_route_table_association" "private_subnet_3_association" {
  subnet_id = aws_subnet.ec2_private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Connect EC2 Private Subnet 2 to Private Route Table 
resource "aws_route_table_association" "private_subnet_4_association" {
  subnet_id = aws_subnet.ec2_private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Creates vpc endpoint to hook up dynamodb
resource "aws_vpc_endpoint" "my_vpc_endpoint" {
  vpc_endpoint_type = "Gateway"
  vpc_id = aws_vpc.my_vpc.id
  service_name = "com.amazonaws.us-east-1.dynamodb" # connects wth dynamodb table associated with my account through this region
  route_table_ids = [aws_route_table.private_route_table.id]
}