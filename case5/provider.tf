### Terraform Providers ###

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

terraform {
  required_providers {
    godaddy = {
      source  = "kolikons/godaddy"
      version = "1.8.1"
    }
  }
}

provider "godaddy" {
  key    = var.godaddy_api_key
  secret = var.godaddy_secret_key
}
