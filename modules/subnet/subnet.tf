resource "aws_subnet" "devops_and_cloud-subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = var.tag_name
  }
}

variable "vpc_id" {
  description = "The VPC ID to attach this subnet to."
}

variable "cidr_block" {
  description = "The subnet address of this subnet."
}

variable "availability_zone" {
  description = "The availability_zone for this subnet."
}

variable "map_public_ip_on_launch" {
  description = "Boolean. If true, EC2 instances assigned to this subnet will automatically have Public IPv4 address."
}

variable "tag_name" {
  description = "The tag name to assign this subnet"
}

output "subnet_id" {
  value = aws_subnet.devops_and_cloud-subnet.id
}

output "cidr_block" {
  value = aws_subnet.devops_and_cloud-subnet.cidr_block
}
