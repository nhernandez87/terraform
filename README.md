# Terraform AWS Infrastructure

Personal AWS infrastructure setup with VPC and EC2 instance.

## Resources Created

- **VPC**: Custom VPC with public subnets
- **EC2 Instance**: t3a.large instance running Amazon Linux 2023
- **Security Group**: Allows SSH access (port 22) from anywhere
- **Storage**: GP3 EBS volume with 50GB

## Prerequisites

1. AWS CLI configured (use `source aws-credentials.sh`)
2. Terraform installed
3. SSH key pair named `aws-ec2` must exist in AWS

## Usage

1. **Configure AWS credentials:**
   ```bash
   source aws-credentials.sh
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review the plan:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

5. **Connect to the instance:**
   After applying, Terraform will output the SSH command. Or use:
   ```bash
   ssh -i ~/.ssh/aws-ec2.pem ec2-user@<public-ip>
   ```

6. **Destroy resources (when done):**
   ```bash
   terraform destroy
   ```

## Configuration

Default values can be changed in `variables.tf` or overridden via command line:
- `aws_region`: us-east-1
- `instance_type`: t3a.large
- `disk_size`: 50 GB
- `ssh_key_name`: aws-ec2

## Cost Optimization

This setup is optimized for minimal cost:
- No NAT Gateway (only public subnets)
- Single EC2 instance
- GP3 storage (cost-effective)
- No load balancers or additional services

