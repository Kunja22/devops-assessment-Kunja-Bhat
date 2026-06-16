# ============================================================
# CUSTOM MODULE: security-groups
# SOW requirement: "at least one custom module"
# Creates SGs for: EKS control plane, worker nodes, bastion
# ============================================================

# --- EKS Control Plane SG ---
resource "aws_security_group" "eks_control_plane" {
  name        = "${var.name_prefix}-eks-control-plane-sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  # Allow HTTPS from worker nodes (kubelet, kubectl)
  ingress {
    description     = "HTTPS from worker nodes"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-eks-control-plane-sg"
  }
}

# --- EKS Worker Nodes SG ---
resource "aws_security_group" "eks_nodes" {
  name        = "${var.name_prefix}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # Nodes talk to each other (pod-to-pod)
  ingress {
    description = "Node-to-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow control plane to reach kubelet
  ingress {
    description     = "Kubelet from control plane"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_control_plane.id]
  }

  egress {
    description = "All outbound (internet via NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-eks-nodes-sg"
    # EKS uses this tag to auto-discover node SGs
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# --- Bastion Host SG (optional but recommended) ---
resource "aws_security_group" "bastion" {
  name        = "${var.name_prefix}-bastion-sg"
  description = "Security group for bastion/jump host"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from your IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs   # never use 0.0.0.0/0 in prod!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-bastion-sg"
  }
}
