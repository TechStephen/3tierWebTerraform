terraform {
    backend "s3" {
      bucket = "my-tf-state-3tierwebapp"
      key    = "terraform.tfstate"
      region = "us-east-1"
    }
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

module "VPC" {
  source = "./VPC"
}

module "Security_Group" {
  source = "./SecurityGroup"
  vpc_id = module.VPC.vpc_id
}

module "IAM" {
  source = "./IAM"
}

module "EC2" {
  source = "./EC2"
  vpc_id = module.VPC.vpc_id
  subnet_ids = module.VPC.private_subnet_ids
  instance_profile_id = module.IAM.instance_profile_id
  public_security_group_id = module.Security_Group.public_security_group_id
  private_security_group_id = module.Security_Group.private_security_group_id
}