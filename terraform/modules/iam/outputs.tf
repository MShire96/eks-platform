output "eks_cluster_policy" {
  value = aws_iam_role_policy_attachment.eks-cluster-policy
}

output "eks_cluster_iam_role_arn" {
  value = aws_iam_role.eks-cluster.arn
  depends_on = [ aws_iam_role_policy_attachment.eks-cluster-policy]
}

output "node_group_iam_role_arn" {
  value = aws_iam_role.eks-node-group.arn
  depends_on = [ 
  aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly, 
  aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
  aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy
  ]
}