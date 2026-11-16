output "vpc_id" {
  value = aws_vpc.eks_platform.id
}

output "private_subnet_ids" {
  value = aws_subnet.eks_private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.eks_public[*].id
}