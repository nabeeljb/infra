variable "igw" {
  description = "The availability_zone for this subnet."
}

variable "subnet_id" {
  description = "The subnet where this natgw be associated to."
}

variable "tag_name" {
  description = "The tag name to assign this subnet"
}

resource "aws_eip" "subnet-private-natgw-natgwip" {
  domain     = "vpc"
  depends_on = [var.igw]
}

resource "aws_nat_gateway" "natgw" {
  allocation_id     = aws_eip.subnet-private-natgw-natgwip.id
  subnet_id         = var.subnet_id
  connectivity_type = "public"

  tags = {
    Name = var.tag_name
  }

  depends_on = [var.igw]
}

output "natgw_id" {
  value = aws_nat_gateway.natgw.id
}
