output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the created VPC"
}

output "public_subnets" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "IDs of the public subnets"
}

output "private_subnets" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "IDs of the private subnets"
}
