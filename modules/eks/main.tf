resource "aws_eks_cluster" "KP" {
  name     = var.cluster_name
  role_arn = aws_iam_role.KP.arn 

  vpc_config {
  
  subnet_ids              = flatten([var.public_subnets[*], var.private_subnets[*]])
  security_group_ids      = ["${aws_security_group.eks-cluster-sg.id}"]
  endpoint_private_access = true
    # subnet_ids              = var.aws_public_subnet
    # endpoint_public_access  = var.endpoint_public_access
    # endpoint_private_access = var.endpoint_private_access
    # public_access_cidrs     = var.public_access_cidrs
    # security_group_ids      = [aws_security_group.node_group_one.id] 
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}


resource "aws_eks_node_group" "KP" {
  cluster_name    = aws_eks_cluster.KP.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.KP.arn
  subnet_ids      = var.aws_public_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one.id]
    ec2_ssh_key               = var.key_pair
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.KP-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.KP-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.KP-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "KP" {
  name = "eks-cluster-KP"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "KP-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.KP.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "KP-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.KP.name
}

resource "aws_iam_role" "KP2" {
  name = "eks-node-group-KP"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "KP-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.KP.name
}

resource "aws_iam_role_policy_attachment" "KP-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.KP.name
}

resource "aws_iam_role_policy_attachment" "KP-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.KP.name
}
