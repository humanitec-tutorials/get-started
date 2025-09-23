provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  create_aws   = var.enabled_cloud_provider == "aws"
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

# Internet Gateway for routing traffic to the internet. Required for image pull from public source
resource "aws_internet_gateway" "igw" {
  count = local.create_aws ? 1 : 0

  vpc_id = aws_vpc.vpc[0].id

  tags = {
    Name = "get-started-igw"
  }
}


# Route Table
resource "aws_route_table" "main" {
  count = local.create_aws ? 1 : 0

  vpc_id = aws_vpc.vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = {
    Name = "get-started-rt"
  }
}

resource "aws_route_table_association" "main" {
  count = local.create_aws ? 2 : 0

  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.main[0].id
}

# EKS auto cluster
resource "aws_eks_cluster" "get-started" {
  count = local.create_aws ? 1 : 0
  name  = local.cluster_name

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn                      = aws_iam_role.cluster[0].arn
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

resource "aws_eks_access_entry" "access" {
  cluster_name  = aws_eks_cluster.get-started[0].name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.get-started[0].name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_role" "node" {
  count = local.create_aws ? 1 : 0
  name  = "eks-auto-node-example"
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
  count      = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  count      = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role" "cluster" {
  count = local.create_aws ? 1 : 0
  name  = "eks-cluster-example"
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
  count      = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  count      = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  count      = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  count      = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  count      = local.create_aws ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster[0].name
}

### AWS Pod Identity for the runner
# Install the Pod Identity add-on to the cluster
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.get-started[0].name
  addon_name   = "eks-pod-identity-agent"
}

# Policy document for Pod Identity
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

# IAM role for the runner
resource "aws_iam_role" "agent_runner_workload_identity_role" {
  name               = "get-started-humanitec-kubernetes-agent-runner"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# IAM role policy attachment to a built-in role
resource "aws_iam_role_policy_attachment" "agent_runner_manage_rds" {
  role       = aws_iam_role.agent_runner_workload_identity_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# EKS Pod Identity association for the agent runner service account to the IAM role
resource "aws_eks_pod_identity_association" "agent_runner" {
  cluster_name    = aws_eks_cluster.get-started[0].name
  namespace       = kubernetes_namespace.humanitec_kubernetes_agent_runner.metadata[0].name
  service_account = "humanitec-kubernetes-agent-runner"
  role_arn        = aws_iam_role.agent_runner_workload_identity_role.arn
}