variable "vpc_id" {
  description = "The VPC that this IGW will belong to."
}

variable "igw_id" {
  description = "The IGW that this route table will use."
}

variable "tag_name" {
  description = "The tag_name to associate the igw."
}

resource "aws_route_table" "public_route" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = var.tag_name
  }
}

output "route_table_id" {
  value = aws_route_table.public_route.id
}
