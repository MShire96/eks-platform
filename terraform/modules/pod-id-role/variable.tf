variable "role_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "service_account" {
  type = string
}

variable "policy_json" {
  description = "IAM permissions policy (JSON) attached to the role"
  type        = string
}