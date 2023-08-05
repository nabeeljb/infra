variable "name_prefix" {}
variable "ami_id" {}
variable "security_groups" {
  type = list
}

variable "iam_instance_profile" {}
variable "user_data_rendered" {}

variable "subnet_ids" {
  type = list
}

variable "target_group_arns" {
  type = list
}

resource "aws_launch_configuration" "petclinic-lc" {
  name_prefix     = var.name_prefix
  image_id        = var.ami_id
  instance_type   = "t2.micro"
  security_groups = var.security_groups

  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data_rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "devops_and_cloud-asg" {
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.petclinic-lc.id
  vpc_zone_identifier  = var.subnet_ids

  target_group_arns = var.target_group_arns

  lifecycle {
    create_before_destroy = true
  }
}
