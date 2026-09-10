provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "trainerstacks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "trainerstacks-vpc"
  }
}

# Subnets
resource "aws_subnet" "trainerstacks_subnet" {
  count = 2
  vpc_id                  = aws_vpc.trainerstacks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.trainerstacks_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "trainerstacks-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "trainerstacks_igw" {
  vpc_id = aws_vpc.trainerstacks_vpc.id

  tags = {
    Name = "trainerstacks-igw"
  }
}

# Route Table
resource "aws_route_table" "trainerstacks_route_table" {
  vpc_id = aws_vpc.trainerstacks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trainerstacks_igw.id
  }

  tags = {
    Name = "trainerstacks-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "trainerstacks_association" {
  count          = 2
  subnet_id      = aws_subnet.trainerstacks_subnet[count.index].id
  route_table_id = aws_route_table.trainerstacks_route_table.id
}

# Security Group for EKS Cluster
resource "aws_security_group" "trainerstacks_cluster_sg" {
  name_prefix = "trainerstacks-cluster-"
  vpc_id      = aws_vpc.trainerstacks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "trainerstacks-cluster-sg"
  }
}

# Security Group for EKS Nodes
resource "aws_security_group" "trainerstacks_node_sg" {
  name_prefix = "trainerstacks-node-"
  vpc_id      = aws_vpc.trainerstacks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "trainerstacks-node-sg"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "trainerstacks" {
  name     = "trainerstacks-cluster"
  role_arn = aws_iam_role.trainerstacks_cluster_role.arn

  vpc_config {
    subnet_ids              = aws_subnet.trainerstacks_subnet[*].id
    security_group_ids      = [aws_security_group.trainerstacks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.trainerstacks_cluster_role_policy
  ]

  tags = {
    Name = "trainerstacks-cluster"
  }
}

# EKS Node Group
resource "aws_eks_node_group" "trainerstacks" {
  cluster_name    = aws_eks_cluster.trainerstacks.name
  node_group_name = "trainerstacks-node-group"
  node_role_arn   = aws_iam_role.trainerstacks_node_group_role.arn
  subnet_ids      = aws_subnet.trainerstacks_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.medium"]

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.trainerstacks_node_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.trainerstacks_node_group_role_policy,
    aws_iam_role_policy_attachment.trainerstacks_node_group_cni_policy,
    aws_iam_role_policy_attachment.trainerstacks_node_group_registry_policy,
    aws_eks_cluster.trainerstacks
  ]

  tags = {
    Name = "trainerstacks-node-group"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "trainerstacks_cluster_role" {
  name = "trainerstacks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "trainerstacks_cluster_role_policy" {
  role       = aws_iam_role.trainerstacks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role for Node Group
resource "aws_iam_role" "trainerstacks_node_group_role" {
  name = "trainerstacks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "trainerstacks_node_group_role_policy" {
  role       = aws_iam_role.trainerstacks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "trainerstacks_node_group_cni_policy" {
  role       = aws_iam_role.trainerstacks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "trainerstacks_node_group_registry_policy" {
  role       = aws_iam_role.trainerstacks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
