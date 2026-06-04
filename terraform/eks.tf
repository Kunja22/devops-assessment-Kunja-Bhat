module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "assessment-eks"
  cluster_version = "1.31"

  vpc_id = aws_vpc.main.id

  subnet_ids = [
    aws_subnet.private_1.id
  ]

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = ["t3.medium"]

      capacity_type = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Project     = "assessment"
  }
}
