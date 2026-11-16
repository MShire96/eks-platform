module "s3" {
  source = "../../modules/state-backend"
  name   = var.s3-name
  tags   = var.tags
}

module "ecr" {
  source = "../../modules/ecr"
}