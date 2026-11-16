variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
  default = "1.37"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "admin_cidr_list" {
  type = list(string)
}

variable "cluster_iam_role_arn" {
  type = string
}

variable "cluster_admin_arns" {
  description = "IAM user/role ARNs that get cluster-admin access"
  type = list(string)
}

variable "node_group_name" {
  type = string
  default = "eks-group"
}

variable "node_group_iam_role_arn" {
  type = string
}

variable "node_volume_size" {
  type = number
  default = 20
}

variable "node_imds_hop_limit" {
  type = number
  default = 1
}

variable "node_ami_type" {
  type = string
  default = "AL2023_x86_64_STANDARD"
}

variable "node_capacity_type" {
  type = string
  default = "ON_DEMAND"
}

variable "node_instance_type" {
  type = list(string)
  default = [ "t3.medium" ]
}

variable "node_desired_size" {
  type = number
  default = 2
}

variable "node_max_size" {
  type = number
  default = 2
}

variable "node_min_size" {
  type = number
  default = 1
}

variable "upgrade_support_type" {
  description = "STANDARD or EXTENDED. Set to null to omit (MiniStack doesn't support it)."
  type        = string
  default     = "STANDARD"
}

variable "emulator_mode" {
  description = "Turn off features the local AWS emulator can't handle."
  type        = bool
  default     = false
}