resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.eks-demo.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = aws_vpc.eks-demo.id
  name   = "eks-cluster-sg"

  description = "Security group for EKS cluster communication"


  # Allow inbound HTTPS traffic from the bastion vm to the EKS control plane
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Allow outbound traffic to the internet (NAT Gateway or Internet Gateway)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}