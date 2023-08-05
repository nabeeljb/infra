variable "tag_name" {}
variable "vpc_id" {}
variable "service_name" {}
variable "subnet_ids" {
  type = list
}
variable "security_group_ids" {
  type = list
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = var.vpc_id
  service_name = var.service_name

  subnet_ids = var.subnet_ids
  security_group_ids = var.security_group_ids
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  dns_options {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name = var.tag_name
  }
}
