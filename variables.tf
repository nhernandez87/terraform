variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "homeserver"
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for the domain"
  type        = string
  default     = "Z05760333R4ZV2HW71X62"
}

variable "domain_name" {
  description = "Domain name for the server"
  type        = string
  default     = "nahuelhernandez.com"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3a.large"
}

variable "disk_size" {
  description = "Size of the root disk in GB"
  type        = number
  default     = 50
}

variable "ssh_key_name" {
  description = "Name of the AWS EC2 Key Pair"
  type        = string
  default     = "aws-ec2"
}

