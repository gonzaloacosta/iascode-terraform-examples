### Terraform Providers ###

provider "aws" {
  version = "~>2.0"
  profile = "admin-network"
  region  = var.region
}

provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}

### Terraform Data ###

data "aws_availability_zones" "available" {}

data "consul_keys" "networking" {
  key {
    name = "networking"
    path = "networking/configuration/semperti-primary/net_info"
  }
}

### Terraform Locals ###

locals {
  cidr_block      = jsondecode(data.consul_keys.networking.var.networking)["cidr_block"]
  private_subnets = jsondecode(data.consul_keys.networking.var.networking)["private_subnets"]
  public_subnets  = jsondecode(data.consul_keys.networking.var.networking)["public_subnets"]
  subnet_count    = jsondecode(data.consul_keys.networking.var.networking)["subnet_count"]
}

### Terraform Resources ###

# NETWORKING #

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "2.64.0"
  name                         = "semperti-primary"
  cidr                         = local.cidr_block
  azs                          = slice(data.aws_availability_zones.available.names, 0, local.subnet_count)
  private_subnets              = local.private_subnets
  public_subnets               = local.public_subnets
  enable_nat_gateway           = false
  create_database_subnet_group = false
  tags = {
    Environment = "Production"
    Team        = "Network"
  }
}






