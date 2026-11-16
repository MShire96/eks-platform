# VPC
resource "aws_vpc" "eks_platform" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# IGW
resource "aws_internet_gateway" "eks_platform" {
  vpc_id = aws_vpc.eks_platform.id
}

# Subs

resource "aws_subnet" "eks_public" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.eks_platform.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "eks_private" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.eks_platform.id
  cidr_block              = var.private_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# NAT 

resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.eks_platform]
}

resource "aws_nat_gateway" "eks_platform" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.eks_public[0].id
  depends_on    = [aws_internet_gateway.eks_platform]
}

# Route tables - pub
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_platform.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_platform.id
}

resource "aws_route_table_association" "public" {
  count = length(var.azs)

  subnet_id      = aws_subnet.eks_public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route - per az

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_platform.id
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_platform.id
}

resource "aws_route_table_association" "private" {
  count = length(var.azs)

  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.private.id
}