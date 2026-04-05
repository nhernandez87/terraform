terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket  = "naguer-terraform-state"
    key     = "personal/terraform.tfstate"
    region  = "us-east-1"
    profile = "naguer"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "naguer"
}

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module - Official AWS VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 0), cidrsubnet(var.vpc_cidr, 8, 1)]
  private_subnets = []

  enable_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security Group for EC2 Instance
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instance - allows SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "n8n web interface"
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP for Caddy"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS for Caddy"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    # ingress rules are managed dynamically by aws-update-ssh-ip script
    ignore_changes = [name, ingress]
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = var.disk_size
    encrypted   = true
  }

  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    hostname = var.project_name
  })

  user_data_replace_on_change = true

  lifecycle {
    # Ignore AMI updates, user_data changes, and root_block_device (encryption
    # can't be changed without replacing the instance).
    ignore_changes = [ami, user_data, root_block_device]
  }

  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route 53 DNS Record
resource "aws_route53_record" "server" {
  zone_id = var.route53_zone_id
  name    = "${var.project_name}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.main.public_ip]
}

# Route 53 DNS Record for n8n subdomain
resource "aws_route53_record" "n8n" {
  zone_id = var.route53_zone_id
  name    = "n8n.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.main.public_ip]
}

