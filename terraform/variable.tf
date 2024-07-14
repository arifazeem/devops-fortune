data "aws_availability_zones" "available" {}
variable "region" {
  description = "The AWS region to create resources in"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "CIDR blocks for the private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for the bastion host"
  default     = "t2.micro"
}

variable "eks_instance_type" {
  description = "EC2 instance type for the bastion host"
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "bastion"
}