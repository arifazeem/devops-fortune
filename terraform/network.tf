resource "aws_vpc" "eks-demo" {
  cidr_block = var.vpc_cidr
  tags = {"Name"="main_vpc"}
}
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.eks-demo.id
  cidr_block = element(var.public_subnets,count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
resource "aws_subnet" "private" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.eks-demo.id
  cidr_block = element(var.private_subnets,count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}
resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat[0].id
  subnet_id = aws_subnet.public[0].id
  tags = {
    Name = "main-nat-gateway"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks-demo.id
  tags= {
    Name = "main-gateway"
  }
}

resource "aws_eip" "nat" {
  count = 1
#   vpc = true
}

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

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks-demo.id
  route {
    gateway_id=aws_nat_gateway.eks_nat.id
    cidr_block="0.0.0.0/0"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
