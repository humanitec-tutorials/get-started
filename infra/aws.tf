provider "aws" {
  region = var.aws_region
}
locals {
  create_aws = var.enabled_cloud_provider == "aws"
  cluster_name = "get-started-eks"
}
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC and networking
resource "aws_vpc" "vpc" {
  count = local.create_aws ? 1 : 0

  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "get-started-vpc"
  }
}

resource "aws_subnet" "subnet" {
  count = local.create_aws ? 2 : 0

  vpc_id            = aws_vpc.vpc[0].id
  cidr_block        = "10.10.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  # Required for EKS
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "get-started-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# EKS auto cluster
resource "aws_eks_cluster" "exget-startedample" {
  count = local.create_aws ? 1 : 0
  name = "${local.cluster_name}"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster[0].arn
  bootstrap_self_managed_addons = false

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.node[0].arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = aws_subnet.subnet[*].id
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]
}

resource "aws_iam_role" "node" {
  count = local.create_aws ? 1 : 0
  name = "eks-auto-node-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  count = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  count = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role" "cluster" {
  count = local.create_aws ? 1 : 0
  name = "eks-cluster-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  count = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  count = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  count = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  count = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  count = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster[0].name
}