variable "vpc_id" {
  description = "The ID of the app vpc"
  type        = string
}

variable "public_subnet_id_1" {
  description = "The ID of the 1st subnet to deploy the EC2 instance"
  type        = string
}

variable "public_subnet_id_2" {
  description = "The ID of the 2nd subnet to deploy the EC2 instance"
  type        = string
}

variable "private_subnet_id_1" {
  description = "The ID of the 1st subnet to deploy the EC2 instance"
  type        = string
}

variable "private_subnet_id_2" {
  description = "The ID of the 2nd subnet to deploy the EC2 instance"
  type        = string
}

variable "instance_profile_id" {
  description = "The ID of the instance profile for admin access to dynamo"
  type        = string
}