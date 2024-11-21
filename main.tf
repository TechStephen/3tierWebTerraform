terraform {
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
  public_subnet_id_1 = module.vpc.public_subnet_1
  public_subnet_id_2 = module.vpc.public_subnet_2
  private_subnet_id_1 = module.vpc.private_subnet_1
  private_subnet_id_2 = module.vpc.private_subnet_2
  instance_profile_id = module.iam.instance_profile_id
}