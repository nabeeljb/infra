variable "tag_name" {}
variable "security_groups" {
  type = list(any)
}
variable "subnet_ids" {
  type = list(any)
}
variable "lb_listener_port" {}
variable "lb_listener_protocol" {}

variable "lb_target_group_port" {}
variable "lb_target_group_protocol" {}

variable "vpc_id" {}

variable "certificate_arn" {}

resource "aws_lb" "lb" {
  name               = var.tag_name
  internal           = false
  load_balancer_type = "application"

  security_groups = var.security_groups
  subnets         = var.subnet_ids

  enable_deletion_protection = false
}

# Target groups will be the port the load balancer will forward the port to on the destination container/server (internal facing)
resource "aws_lb_target_group" "lb-tg" {
  name     = join("-", [var.tag_name, "tb-tg"])
  port     = var.lb_target_group_port
  protocol = var.lb_target_group_protocol
  vpc_id   = var.vpc_id
  stickiness {
    type = "lb_cookie"
  }

  health_check {
    port = 8080
  }
}

# These will be the ports that the load balancer will be listening to (internet facing)
resource "aws_lb_listener" "lb-listen-http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.lb-tg.arn
    type             = "forward"
  }
}

output "lb" {
  value = aws_lb.lb
}

output "lb_target_group" {
  value = aws_lb_target_group.lb-tg
}

output "aws_lb_listener" {
  value = aws_lb_listener.lb-listen-http
}

# These will be the ports that the load balancer will be listening to (internet facing)
# resource "aws_lb_listener" "devops-and-cloud-lb-tg-l-https" {
#   load_balancer_arn = aws_lb.devops-and-cloud-lb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "${var.certificate_arn}"

#   default_action {
#     target_group_arn  = aws_lb_target_group.devops-and-cloud-lb-tg.arn
#     type              = "forward"
#   }
# }

# resource "aws_route53_record" "petclinic-a-record" {
#   zone_id = data.aws_route53_zone.ROUTE53_HOSTED_ZONE_NAME.id
#   name    = "petclinic-a-record"
#   type    = "A"
#   alias {
#     name    = aws_lb.devops-and-cloud-lb.dns_name
#     zone_id = aws_lb.devops-and-cloud-lb.zone_id
#     evaluate_target_health = true
#   }
# }
