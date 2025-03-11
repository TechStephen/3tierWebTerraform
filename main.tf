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
  source = "./vpc"
}

module "Security_Groups" {
  source = "./security_groups"
  vpc_id = module.VPC.vpc_id
}

module "IAM" {
  source = "./iam"
}

module "API_Gateway" {
  source = "./api_gateway"
  invoke_arn = module.Lambda.invoke_arn
}

module "Lambda" {
  source = "./lambda"
  lambda_role_arn = module.IAM.lambda_role_arn
  execution_arn = module.API_Gateway.execution_arn
}

module "EC2" {
  source = "./ec2"
  vpc_id = module.VPC.vpc_id
  subnet_ids = module.VPC.subnet_ids
  instance_profile_id = module.IAM.instance_profile_id
  public_security_group_id = module.Security_Groups.public_security_group_id
  private_security_group_id = module.Security_Groups.private_security_group_id
}