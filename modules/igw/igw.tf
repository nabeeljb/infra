variable "vpc_id" {
  description = "The VPC that this IGW will belong to."
}

variable "tag_name" {
  description = "The tag_name to associate the igw."
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.tag_name
  }
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}
