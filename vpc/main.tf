# Creates vpc
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16" # provide cidr block
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      name = "my-vpc"
    }
}

# Creates private subnet 1 (us-east-1a)
resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
      Name = "PrivateSubnet1"
    }
}

# Creates private subnet 2 (us-east-1b)
resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
      Name = "PrivateSubnet2"
    }
}

# Creates private subnet 3 (us-east-1a)
resource "aws_subnet" "private_subnet_3" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
      Name = "PrivateSubnet3"
    }
}

# create private subnet 4 (us-east-1b)
resource "aws_subnet" "private_subnet_4" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
      Name = "PrivateSubnet4"
    }
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "MyInternetGateway"
    }
}

# Create route table (needed to connect to igw)
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "PublicRouteTable"
    }
}

# Create route connect subnet to internet gateway
resource "aws_route" "public_internet_route" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id = aws_route_table.public_route_table.id
    gateway_id = aws_internet_gateway.my_igw.id
}

# Connect Public Subnet 1 to Route Table
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Connect Public Subnet 2 to Route Table
resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Private Route Table (For DynamoDB AWS will automatically configure route)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "PrivateRouteTable"
  }
}

# Connect Private Subnet 3 to Route Table 
resource "aws_route_table_association" "private_subnet_3_association" {
  subnet_id = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}

# Connect Private Subnet 4 to Route Table 
resource "aws_route_table_association" "private_subnet_4_association" {
  subnet_id = aws_subnet.private_subnet_4.id
  route_table_id = aws_route_table.private_route_table.id
}

# Creates vpc endpoint to hook up dynamodb
resource "aws_vpc_endpoint" "my_vpc_endpoint" {
  vpc_endpoint_type = "Gateway"
  vpc_id = aws_vpc.my_vpc.id
  service_name = "com.amazonaws.us-east-1.dynamodb" # connects wth dynamodb table associated with my account through this region
  route_table_ids = [aws_route_table.private_route_table.id]
}