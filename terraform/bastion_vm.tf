resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[1].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  associate_public_ip_address = true

  user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install -y awscli
                curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
                chmod +x kubectl
                mv kubectl /usr/local/bin/
                aws eks update-kubeconfig --region ap-south-1 --name private_eks_cluster
                kubectl get cm aws-auth -n kube-system -o yaml > aws-auth.yaml
                EOF

  tags = {
    Name = "bastion-host"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}