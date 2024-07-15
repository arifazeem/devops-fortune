resource "aws_eks_cluster" "eks_cluster" {
  name = "private_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [ aws_subnet.private[0].id,aws_subnet.private[1].id ]
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids = [ aws_security_group.eks_cluster_sg.id ]
  }
   depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}
resource "aws_eks_node_group" "eks_node_group" {
  node_group_name = "eks_node_group"
  cluster_name =  aws_eks_cluster.eks_cluster.name
  node_role_arn = aws_iam_role.eks-node-role.arn
  subnet_ids = [ aws_subnet.private[0].id,aws_subnet.private[1].id ]
  instance_types = [ var.eks_instance_type ]
  scaling_config {
    desired_size = 3
    max_size     = 3    
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy
  ]

  tags = {
    Name = "eks-node-group"
  }
}