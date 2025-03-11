output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  value = [aws_subnet.lb_public_subnet_1.id, aws_subnet.lb_public_subnet_2.id, aws_subnet.ec2_private_subnet_1.id, aws_subnet.ec2_private_subnet_2.id]
}