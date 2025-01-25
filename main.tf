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

module "iam" {
  source = "./iam"
}

module "vpc" {
  source = "./vpc"
}

module "ec2" {
  source = "./ec2"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  instance_profile_id = module.iam.instance_profile_id
}