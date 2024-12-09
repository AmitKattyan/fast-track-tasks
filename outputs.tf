output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "alb_dns" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns
}

output "eks_cluster_id" {
  value = module.eks_cluster.eks_cluster_id
}

output "eks_vpc_id" {
  value = module.eks_cluster.eks_vpc_id
}

output "mysql_endpoint" {
  description = "The connection endpoint for the MySQL database instance"
  value       = aws_db_instance.mysql.endpoint
}

output "mysql_instance_id" {
  description = "The ID of the MySQL RDS instance"
  value       = aws_db_instance.mysql.id
}

output "bucket_name" {
  value = aws_s3_bucket.static_assets.id
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}
