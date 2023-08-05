variable "tag_name" {
  description = "The tag_name to associate the igw."
}

variable "natgw_id" {
  description = "The NAT Gateway id to use to route traffic."
}

variable "vpc_id" {
  description = "The VPC that this route table will belong to."
}

resource "aws_route_table" "subnet-private1-routes" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.natgw_id
  }

  tags = {
    Name = var.tag_name
  }
}

output "aws_route_table_id" {
  value = aws_route_table.subnet-private1-routes.id
}
