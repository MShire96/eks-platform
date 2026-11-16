

resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  role_arn = var.cluster_iam_role_arn
  version  = var.kubernetes_version

  bootstrap_self_managed_addons = false

  dynamic "upgrade_policy" {
    for_each = var.upgrade_support_type == null ? [] : [1]
    content {
      support_type = var.upgrade_support_type
    }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = var.private_subnet_ids
    public_access_cidrs = var.admin_cidr_list
  }
}


resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_group_iam_role_arn
  subnet_ids      = var.private_subnet_ids
  version = aws_eks_cluster.cluster.version

  ami_type = var.node_ami_type
  capacity_type = var.node_capacity_type
  instance_types = var.node_instance_type

  dynamic "launch_template" {
    for_each = var.emulator_mode ? [] : [1]
    content {
      id      = aws_launch_template.eks_nodes[0].id
      version = aws_launch_template.eks_nodes[0].latest_version
    }
  }

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  dynamic "update_config" {
    for_each = var.emulator_mode ? [] : [1]
    content {
      max_unavailable = 1
    }
  }
}

resource "aws_launch_template" "eks_nodes" {
  count = var.emulator_mode ? 0 : 1
  name_prefix = "${var.cluster_name}-nodes-"


  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size = var.node_volume_size
      volume_type = "gp3"
      encrypted = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
    http_put_response_hop_limit = var.node_imds_hop_limit
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.node]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.node]
}