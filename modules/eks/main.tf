#######modules/eks/main.tf

### EKS CLUSTER ###

resource "random_integer" "suffix" {
  min = 10
  max = 200
}

resource "aws_eks_cluster" "KP" {
  name     = "KP"
  role_arn = aws_iam_role.KP.arn

  vpc_config {
    subnet_ids = [aws_subnet.KP1.id, aws_subnet.KP2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.KP-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.KP-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.KP.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.KP.certificate_authority[0].data
}

#EKS NODE GROUP#
resource "aws_eks_node_group" "KP" {
  cluster_name    = aws_eks_cluster.KP.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.KP2.arn
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

#IAM ROLE#

resource "aws_eks_node_group" "KP" {
  cluster_name    = aws_eks_cluster.KP.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.KP2.arn
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

### IAM ROLE ##

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

### IAM ROLE ATTACHMENT ###

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


### SECURITY GROUPS ###

resource "aws_security_group" "node_group_kp" {
  name_prefix = "node_group_kp"
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

resource "aws_security_group_rule" "eks-cluster-ingress-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster-sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "eks-node-sg" {
  name        = "${var.name}-node-sg"
  vpc_id      = var.vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### WORKER NODE ROLE ###

resource "aws_iam_role" "KP" {
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

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example.name
}