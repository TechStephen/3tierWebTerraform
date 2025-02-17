variable "vpc_id" {
  description = "The ID of the app vpc"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets for the app"
  type        = list(string)  
}

variable "instance_profile_id" {
  description = "The ID of the instance profile"
  type        = string
}

variable "public_security_group_id" {
  description = "The ID of the public security group"
  type        = string
}

variable "private_security_group_id" {
  description = "The ID of the private security group"
  type        = string
}