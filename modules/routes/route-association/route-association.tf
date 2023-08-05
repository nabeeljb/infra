variable "subnet_id" {
  description = "The subnet id that will assign this route to."
}

variable "route_table_id" {
  description = "The route table to marry to the subnet_id."
}

resource "aws_route_table_association" "devops_and_cloud-subnet-public1" {
  subnet_id      = var.subnet_id
  route_table_id = var.route_table_id
}
