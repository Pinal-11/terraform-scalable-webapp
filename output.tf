output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.tf_main.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = aws_subnet.tf_Public_Subnet[*].id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = aws_subnet.tf_Private_Subnet[*].id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS"
  value       = aws_lb.tf_ALB.dns_name
}
