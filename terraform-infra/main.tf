# ============================================================
# ROOT MAIN.TF
# Uses:
#   1. clouddrove/vpc/aws          → VPC, subnets, route tables, NAT
#   2. clouddrove/eks/aws          → EKS cluster + node group
#   3. ./modules/security-groups   → Custom module (SOW requirement)
# ============================================================

locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"
  name_prefix  = "${var.project_name}-${var.environment}"
}

# ============================================================
# 1. VPC — clouddrove module
#    Handles: VPC, public subnets, private subnets,
#             Internet Gateway, NAT Gateway, route tables
# ============================================================
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name        = "${local.name_prefix}-vpc"
  environment = var.environment

  # VPC CIDR
  vpc_id   = ""          # will be created
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Subnets
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  # NAT Gateway (one per AZ = HA, one total = cheaper)
  enable_nat_gateway     = true
  single_nat_gateway     = true   # set false for full HA
  enable_internet_gateway = true

  # EKS needs these tags on subnets for load balancer auto-discovery
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# ============================================================
# 2. SECURITY GROUPS — your custom module
# ============================================================
module "security_groups" {
  source = "./modules/security-groups"

  vpc_id            = module.vpc.vpc_id
  name_prefix       = local.name_prefix
  cluster_name      = local.cluster_name
  allowed_ssh_cidrs = ["YOUR.IP.ADDRESS.HERE/32"]  # apna IP dalo
}

# ============================================================
# 3. EKS CLUSTER — clouddrove module
#    SOW requirement: "at least one clouddrove/terraform module"
# ============================================================
module "eks" {
  source  = "clouddrove/eks/aws"
  version = "2.0.0"

  name        = local.cluster_name
  environment = var.environment

  # Networking
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids   # nodes go in private subnets
  
  # Control plane SG from our custom module
  cluster_security_group_ids = [module.security_groups.control_plane_sg_id]

  # EKS version
  cluster_version = var.eks_cluster_version

  # Endpoint access (control plane)
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true   # set false once bastion is ready

  # Node group
  node_groups = {
    default = {
      name           = "${local.name_prefix}-node-group"
      instance_types = [var.node_instance_type]
      ami_type       = "AL2_x86_64"

      scaling_config = {
        desired_size = var.node_desired_capacity
        min_size     = var.node_min_capacity
        max_size     = var.node_max_capacity
      }

      # Nodes in private subnets only
      subnet_ids = module.vpc.private_subnet_ids

      # Attach custom node SG
      security_group_ids = [module.security_groups.nodes_sg_id]

      labels = {
        Environment = var.environment
        NodeGroup   = "default"
      }

      tags = {
        Name = "${local.name_prefix}-node"
      }
    }
  }

  # Enable CloudWatch logging
  cluster_enabled_log_types = ["api", "audit", "authenticator"]

  depends_on = [module.vpc, module.security_groups]
}
