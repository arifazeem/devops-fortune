# Create an EKS cluster with a private endpoint
resource "aws_eks_cluster" "eks_cluster" {
  name     = "private_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  # Configure VPC settings for the EKS cluster
  vpc_config {
    subnet_ids               = [aws_subnet.private[0].id, aws_subnet.private[1].id] # Use private subnets
    endpoint_private_access  = true  # Enable private access to the API endpoint
    endpoint_public_access   = false # Disable public access to the API endpoint
    security_group_ids       = [aws_security_group.eks_cluster_sg.id] # Security group for the cluster
  }

  # Ensure IAM role policy attachment is created before the cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# Create an EKS node group
resource "aws_eks_node_group" "eks_node_group" {
  node_group_name = "eks_node_group"
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_role_arn   = aws_iam_role.eks-node-role.arn

  # Use private subnets for the node group
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  # Define the instance types and scaling configuration for the node group
  instance_types = [var.eks_instance_type]

  scaling_config {
    desired_size = 3 # Desired number of nodes
    max_size     = 3 # Maximum number of nodes
    min_size     = 1 # Minimum number of nodes
  }

  # Ensure IAM role policy attachment is created before the node group
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy
  ]

  # Tags for the node group
  tags = {
    Name = "eks-node-group"
  }
}
