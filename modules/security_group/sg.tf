variable "description" {
  description = "The description for this security group."
}

variable "vpc_id" {
  description = "The VPC ID object where this security is associated."
}

variable "ingress_port_range" {
  type = list
  description = "The port range for ingress. [0] - Starting. [1] - Ending."
}

variable "ingress_protocol" {
  description = "The allowed inbound protocol. -1 for all."
}

variable "ingress_cidr_blocks" {
  type = list
  description = "The allowed source cidr_block for inbound connections."
}

variable "egress_port_range" {
  type = list
  description = "The port range for egress. [0] - Starting. [1] - Ending."
}

variable "egress_protocol" {
  description = "The allowed outbound protocol. -1 for all."
}

variable "egress_cidr_blocks" {
  type = list
  description = "The allowed source cidr_block for inbound connections."
}

variable "tag_name" {
  description = "The tag name to associate this security group."
}

resource "aws_security_group" "rule" {
  name        = var.tag_name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    description = var.description
    from_port   = var.ingress_port_range[0]
    to_port     = var.ingress_port_range[1]
    protocol    = var.ingress_protocol
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port   = var.egress_port_range[0]
    to_port     = var.egress_port_range[1]
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = {
    Name = var.tag_name
  }
}

output "security_group_id" {
  value = aws_security_group.rule.id
}
