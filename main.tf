terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.79.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source               = "./modules/vpc"
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ALB Module
module "alb" {
  source         = "./modules/alb"
  public_subnets = module.vpc.public_subnets
  vpc_id         = module.vpc.vpc_id
  environment    = var.environment
}
  
module "eks_cluster" {
  source = "./modules/eks"
  vpc_cidr              = "10.1.0.0/16"
  subnet_1_cidr         = "10.1.1.0/24"
  subnet_2_cidr         = "10.1.2.0/24"
  cluster_name          = "my-eks-cluster"
  node_group_name       = "my-node-group"
  instance_type         = "t3.medium"
  node_group_min_size   = 1
  node_group_max_size   = 4
  node_group_desired_size = 2
}

# RDS Setup
# VPC (Optional: Use existing VPC ID)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Subnets
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
}

# Security Group for MySQL
resource "aws_security_group" "mysql" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Restrict to your VPC CIDR or specific IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier              = "mysql-instance"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  multi_az                = true
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.mysql.name
  vpc_security_group_ids  = [aws_security_group.mysql.id]
  username                = "admin"
  password                = "yourpassword" # Use a secure password
  skip_final_snapshot     = true
}
# S3 Bucket
resource "aws_s3_bucket" "static_assets" {
  bucket = "static-assets-${var.environment}-${random_string.suffix.result}"
  acl    = "public-read"

  tags = {
    Name        = "Static Assets Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "static_assets_versioning" {
  bucket = aws_s3_bucket.static_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "static_assets_lifecycle" {
  bucket = aws_s3_bucket.static_assets.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_assets.arn}/*"
      }
    ]
  })
}

resource "random_string" "suffix" {
  length  = 6
  special = false
}

# IAM Roles and Policies
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "EC2S3AccessPolicy"
  description = "Policy to allow EC2 instances to interact with S3 bucket"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.static_assets.arn,
          "${aws_s3_bucket.static_assets.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}



