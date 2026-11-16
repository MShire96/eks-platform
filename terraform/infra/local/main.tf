module "vpc" {
  source = "../../modules/vpc"
  tags   = var.tags
}

module "iam" {
  source = "../../modules/iam"
}

module "eks" {
  source = "../../modules/eks"
  cluster_name = var.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  admin_cidr_list = var.admin_cidr_list
  cluster_admin_arns = var.cluster_admin_arns
  cluster_iam_role_arn = module.iam.eks_cluster_iam_role_arn
  node_group_iam_role_arn = module.iam.node_group_iam_role_arn
  upgrade_support_type = null
  emulator_mode = true
}

module "platform" {
  source       = "../../modules/platform"
  environment  = "local"
  cluster_name = module.eks.cluster_name
  zone_arn     = aws_route53_zone.main.arn # zone from dns.tf
  depends_on = [module.eks]   
}