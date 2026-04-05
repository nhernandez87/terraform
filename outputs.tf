output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.main.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ec2-user@${aws_route53_record.server.fqdn}"
}

output "dns_name" {
  description = "DNS name for the server"
  value       = aws_route53_record.server.fqdn
}

output "overlord_url" {
  description = "URL for the Overlord dashboard"
  value       = "https://${aws_route53_record.overlord.fqdn}"
}

output "deskpact_nameservers" {
  description = "Paste these 4 NS into Namecheap > Domain > Nameservers > Custom DNS"
  value       = aws_route53_zone.deskpact.name_servers
}

output "clientmate_nameservers" {
  description = "Paste these 4 NS into Namecheap > Domain > Nameservers > Custom DNS"
  value       = aws_route53_zone.clientmate.name_servers
}

