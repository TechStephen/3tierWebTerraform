variable "vpc_id" {
  description = "The ID of the app vpc"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets for the app"
  type        = list(string)  
}

variable "instance_profile_id" {
  description = "The ID of the instance profile for admin access to dynamo"
  type        = string
}