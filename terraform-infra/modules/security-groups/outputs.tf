output "control_plane_sg_id" {
  description = "SG ID for EKS control plane"
  value       = aws_security_group.eks_control_plane.id
}

output "nodes_sg_id" {
  description = "SG ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "bastion_sg_id" {
  description = "SG ID for bastion host"
  value       = aws_security_group.bastion.id
}
