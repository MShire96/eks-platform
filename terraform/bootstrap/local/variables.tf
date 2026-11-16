variable "tags" {
  default = {
    Environment = "vscode"
    Project     = "eks-platform"
    Owner       = "Mohamed"
    Use         = "Bootstrap"
  }
}

variable "s3-name" {
  default = "eks-platform-backend"
}