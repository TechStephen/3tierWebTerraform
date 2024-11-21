# Create route table (needed to connect to igw)
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "PublicRouteTable"
    }
}

# Create route within route table to connect subnet to internet gateway
resource "aws_route" "public_internet_route" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id = aws_route_table.public_route_table.id
    gateway_id = aws_internet_gateway.my_igw.id
  
}

# Connect Public Subnet 1 to Route Table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Connect Public Subnet 2 to Route Table
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Private Route Table (For DynamoDB AWS will automatically configure route)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "PrivateRouteTable"
  }
}

# Connect Private Subnet 1 to Route Table 
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Connect Private Subnet 2 to Route Table 
resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}