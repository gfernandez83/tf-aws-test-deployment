terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
        }
    }

    required_version = ">= 1.1.0"
}

provider "aws" {
    region = "ap-northeast-1"

    default_tags {
        tags = {
            Name      = "TF-AWS-Test-Deployment"
            ManagedBy = "Terraform"
        }
    }
}


module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name                   = "TF-AWS-Test-VPC"
    cidr                   = "172.20.168.0/21"
    azs                    = data.aws_availability_zones.available.names
    public_subnets         = ["172.20.168.0/24", "172.20.170.0/24", "172.20.172.0/24"]
    private_subnets        = ["172.20.169.0/24", "172.20.171.0/24", "172.20.173.0/24"]
    enable_nat_gateway     = true
    one_nat_gateway_per_az = false
    single_nat_gateway     = true
    enable_dns_hostnames   = true
}