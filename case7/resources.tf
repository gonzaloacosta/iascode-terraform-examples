### Terraform Providers ###

provider "aws" {
  version = "~>2.0"
  profile = "admin-network"
  region  = var.region
}

### Terraform Data ###

data "aws_availability_zones" "available" {}

### Terraform Resources ###

# Networking #
module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "2.64.0"
  name                         = "semperti-primary"
  cidr                         = var.cidr_block
  azs                          = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)
  private_subnets              = var.private_subnets
  public_subnets               = var.public_subnets
  enable_nat_gateway           = true
  create_database_subnet_group = false

  tags = {
    Environment = "Production"
    Team        = "Network"
  }
}
