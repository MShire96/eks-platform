variable "environment" {
  description = "local or aws. Picks which helm-values override files to load."
  type        = string
  validation {
    condition     = contains(["local", "aws"], var.environment)
    error_message = "environment must be local or aws."
  }
}

variable "cluster_name" {
  type = string
}

variable "zone_arn" {
  description = "Route53 hosted zone that ExternalDNS and cert-manager may write to."
  type        = string
}