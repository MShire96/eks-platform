variable "terraform-deployment-role-arn" {
  type    = string
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "vscode"
    Project     = "eks-platform"
    Owner       = "Mohamed"
    Use         = "Bootstrap"
  }
}

variable "cluster_name" {
  type = string
  default = "eks-platform-cluster"
}

variable "domain_name" {
  description = "Domain for the hosted zone"
  type        = string
}

variable "admin_cidr_list" {
  description = "CIDRs allowed to reach the public EKS API endpoint"
  type        = list(string)
}

variable "cluster_admin_arns" {
  description = "IAM ARNs that get cluster-admin access"
  type        = list(string)
}
