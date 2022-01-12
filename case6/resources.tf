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


### Terraform Data ###

data "aws_availability_zones" "available" {}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "public_cidrsubnet" {
  count = var.subnet_count[terraform.workspace]

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars = {
    vpc_cidr      = var.network_address_space[terraform.workspace]
    current_count = count.index
  }
}

### Terraform Resources ### 

# Random ID #
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

# Networking #
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "${local.env_name}-vpc"
  version = "2.64.0"

  cidr            = var.network_address_space[terraform.workspace]
  azs             = slice(data.aws_availability_zones.available.names, 0, var.subnet_count[terraform.workspace])
  public_subnets  = data.template_file.public_cidrsubnet[*].rendered
  private_subnets = []

  tags = local.common_tags
}

# Security Groups #

resource "aws_security_group" "elb-sg" {
  name   = "nginx_elb_sg"
  vpc_id = module.vpc.vpc_id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.env_name}-elb-sg" })

}

# Nginx security group 

resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = module.vpc.vpc_id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.network_address_space[terraform.workspace]]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.env_name}-nginx-sg" })

}

# Load Balancer #

resource "aws_elb" "web" {
  name = "${local.env_name}-nginx-elb"

  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.elb-sg.id]
  instances       = aws_instance.nginx[*].id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = merge(local.common_tags, { Name = "${local.env_name}-elb" })

}

# EC2 #

resource "aws_instance" "nginx" {
  count                  = var.instance_count[terraform.workspace]
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = var.instance_size[terraform.workspace]
  subnet_id              = module.vpc.public_subnets[count.index % var.subnet_count[terraform.workspace]]
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  key_name               = var.key_name
  iam_instance_profile   = module.bucket.instance_profile.name
  depends_on             = [module.bucket]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

  provisioner "file" {
    content     = <<EOF
access_key =
secret_key =
security_token =
use_https = True
bucket_location = US

EOF
    destination = "/home/ec2-user/.s3cfg"
  }

  provisioner "file" {
    content = <<EOF
/var/log/nginx/*log {
    daily
    rotate 10
    missingok
    compress
    sharedscripts
    postrotate
    endscript
    lastaction
        INSTANCE_ID=`curl --silent http://169.254.169.254/latest/meta-data/instance-id`
        sudo /usr/local/bin/s3cmd sync --config=/home/ec2-user/.s3cfg /var/log/nginx/ s3://${module.bucket.bucket.id}/nginx/$INSTANCE_ID/
    endscript
}

EOF

    destination = "/home/ec2-user/nginx"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
      "sudo cp /home/ec2-user/.s3cfg /root/.s3cfg",
      "sudo cp /home/ec2-user/nginx /etc/logrotate.d/nginx",
      "sudo pip install s3cmd",
      "s3cmd get s3://${module.bucket.bucket.id}/website/index.html .",
      "s3cmd get s3://${module.bucket.bucket.id}/website/Semperti.png .",
      "sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html",
      "sudo cp /home/ec2-user/Semperti.png /usr/share/nginx/html/Semperti.png",
      "sudo logrotate -f /etc/logrotate.conf"

    ]
  }

  tags = merge(local.common_tags, { Name = "${local.env_name}-nginx${count.index + 1}" })
}

# S3 Bucket config#

module "bucket" {
  name = local.s3_bucket_name

  source      = ".\\Modules\\s3"
  common_tags = local.common_tags
}

resource "aws_s3_bucket_object" "website" {
  bucket = module.bucket.bucket.id
  key    = "/website/index.html"
  source = "./index.html"

}

resource "aws_s3_bucket_object" "graphic" {
  bucket = module.bucket.bucket.id
  key    = "/website/Semperti.png"
  source = "./Semperti.png"

}

# Azure RM DNS #
resource "azurerm_dns_cname_record" "elb" {
  name                = "${local.env_name}-website"
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_resource_group
  ttl                 = "30"
  record              = aws_elb.web.dns_name
  provider            = azurerm.arm-1

  tags = merge(local.common_tags, { Name = "${local.env_name}-website" })
}


resource "godaddy_domain_record" "gd-galab-biz" {
  domain   = var.dns_zone_name
  customer = var.godaddy_customer_id

  record {
    name = "${local.env_name}-web-${var.dns_zone_name}"
    type = "CNAME"
    data = aws_elb.web.dns_name
    ttl  = 3600
  }

  record {
    name     = "www"
    type     = "CNAME"
    data     = "@"
    ttl      = 3600
    priority = 0
  }

  record {
    name     = "_domainconnect"
    data     = "_domainconnect.gd.domaincontrol.com"
    priority = 0
    ttl      = 3600
    type     = "CNAME"
  }
}
