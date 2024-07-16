# Create a Virtual Private Cloud (VPC) with a specified CIDR block
resource "aws_vpc" "eks-demo" {
  cidr_block = var.vpc_cidr
  tags = {"Name"="main_vpc"}
}

# Create public subnets within the VPC
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.eks-demo.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create private subnets within the VPC
resource "aws_subnet" "private" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.eks-demo.id
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Create a NAT Gateway for the VPC
resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat[0].id
  subnet_id = aws_subnet.public[0].id
  tags = {
    Name = "main-nat-gateway"
  }
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks-demo.id
  tags= {
    Name = "main-gateway"
  }
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  count = 1
  # vpc = true
}

# Create a route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Create a route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks-demo.id

  route {
    gateway_id = aws_nat_gateway.eks_nat.id
    cidr_block = "0.0.0.0/0"
  }
}

# Associate the private route table with the private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
