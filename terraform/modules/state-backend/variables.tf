variable "s3-backend-bucket" {
  type    = string
  default = "eks-platform-backend"
}

variable "name" {
  type    = string
  default = "state-backend"
}

variable "tags" {
  type    = map(any)
  default = {}
}