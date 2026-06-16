variable "vpc_id" {
  description = "VPC ID where SGs will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (used in SG tags)"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "Your IP CIDR for bastion SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]   # override this in tfvars!
}
