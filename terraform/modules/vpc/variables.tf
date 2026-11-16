variable "tags" {
  type    = map(string)
  default = {}
}

variable "cluster_name" {
  type    = string
  default = "eks-platform-cluster"
}

variable "public_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_cidrs" {
  default = ["10.0.32.0/19", "10.0.64.0/19"]
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}
