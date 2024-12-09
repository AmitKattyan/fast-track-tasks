# fast-track-tasks
AWS Scalable Web Application Infrastructure

This repository contains an Infrastructure as Code (IaC) solution using Terraform to deploy a scalable, highly available web application infrastructure on AWS. The setup includes:

VPC: Public and private subnets across two availability zones.

Application Load Balancer (ALB): For distributing incoming traffic across multiple EC2 instances.

Auto Scaling Group (ASG): Automatically scales the EC2 instances based on demand.

RDS (mySQL): A multi-AZ database instance for high availability.

S3 Bucket: For storing static assets with versioning and lifecycle policies.

IAM Roles and Policies: Secure and least-privilege access for resources.

Features
Scalable infrastructure with high availability.
Public and private subnet segregation.
Load balancing with automatic failover.
Secure database access restricted to private subnets.
Static asset storage with public access for delivery and lifecycle management.

Getting Started
Prerequisites
Ensure the following are installed on your local machine:

Terraform CLI
AWS CLI
AWS account credentials configured in your environment.
Directory Structure

project-directory/
├── main.tf                # Main Terraform configuration
├── variables.tf           # Global variables
├── outputs.tf             # Outputs
├── vpc/                   # VPC setup
├── eks/                   # Compute EKS setup
├── alb/                   # ALB SETUP

##---Deployment Instructions---##
Pre-requisites:

Install Terraform CLI.
Configure AWS CLI with credentials for a user with appropriate permissions.
Steps:

Clone this repo
Navigate to the root directory.
Initialize Terraform:
terraform init
Plan the deployment:
terraform plan
Apply the deployment:
terraform apply
Provide required input values (e.g., environment, database password).

Wait for Terraform to complete the deployment.
##---Outputs---##
Note the outputs such as:
VPC ID
Subnet IDs
ALB DNS name
RDS endpoint
S3 bucket name
Modifying Parameters:

##---Testing and Validation---##
1.Ensure EC2 Instances Serve Web Traffic and Scale Correctly
Steps:
Deploy the infrastructure.
Launch EC2 instances in the Auto Scaling Group (ASG).
Deploy a simple web application on the EC2 instances (e.g., a static "Hello World" HTML page or a simple API).
Monitor Auto Scaling triggers (e.g., CPU utilization). Verify that instances scale up/down as per the defined policies.
Expected Outcome:
Application is accessible at the ALB's DNS endpoint.
Auto Scaling adds/removes EC2 instances based on traffic demand.
2. Verify ALB Traffic Distribution
Steps:
Access the ALB's DNS name in a browser or via curl to make multiple HTTP requests.
Log into the EC2 instances and inspect application logs to confirm the distribution of requests across multiple instances.
Expected Outcome:
Traffic is distributed evenly across the EC2 instances.
3. Check RDS Instance Connectivity
Steps:
SSH into one of the EC2 instances in the private subnet.
Use the RDS endpoint to connect to the database using a tool like mysql
mysql -h <RDS_ENDPOINT> -U <DB_USERNAME> -d <DB_NAME>
Attempt to perform basic SQL queries to verify connectivity.
Expected Outcome:
EC2 instances can connect to the RDS instance.
RDS is not accessible from the public internet.
4. Validate S3 Bucket Accessibility
Steps:
Upload a sample static asset (e.g., an image) to the S3 bucket.
Use the object's public URL to verify that it is accessible from a browser.
Test object upload and retrieval via the EC2 instances.
Check that the bucket’s versioning is enabled and lifecycle policies are applied.
Expected Outcome:
Public objects in the S3 bucket are accessible.
Objects have versioning enabled, and old versions are managed by the lifecycle policy.

##---Tear down the infra---##
terraform destroy-Always check before running this command
