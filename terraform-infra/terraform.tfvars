# ============================================================
# terraform.tfvars — production values
# DO NOT commit this file if it has secrets (use .gitignore)
# ============================================================

aws_region   = "ap-south-1"
environment  = "prod"
project_name = "sow"

# VPC
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b"]

# EKS
eks_cluster_version   = "1.29"
node_instance_type    = "t3.medium"
node_desired_capacity = 2
node_min_capacity     = 1
node_max_capacity     = 4
