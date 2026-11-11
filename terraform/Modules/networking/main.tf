locals {
  tags = {
    Terraform   = "true" # Managed by Terraform, do not modify manually
    Environment = "dev"
    Project     = "ecommerce-app"
    Owner       = "devops-team"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name       = "vpc-ecommerce-project"
  cidr       = "10.0.0.0/16"
  create_igw = true

  azs = ["us-east-1a", "us-east-1b"]

  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.10.0/24", "10.0.20.0/24"]

  private_subnet_names  = ["app-1", "app-2"]
  public_subnet_names   = ["alb-1", "alb-2"]
  database_subnet_names = ["database-1", "database-2"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # Separate route table for database subnets: local VPC route only, no NAT
  create_database_subnet_route_table = true

  tags = local.tags
}

# Free S3 gateway endpoint on the private (app) route tables only.
# Keeps S3 traffic (ECR image layers, future media bucket) off the NAT Gateway.
module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "s3-gateway-endpoint" }
    }
  }

  tags = local.tags
}
