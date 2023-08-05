resource "aws_vpc" "devops_and_cloud-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "devops_and_cloud-vpc"
  }
}

variable "cidr_block" {
  description = "The cidr block of the network in the format of 172.32.0.0/16"
}

output "vpc_id" {
  value = aws_vpc.devops_and_cloud-vpc.id
}
