variable "subnet_ids" {
  type        = list(any)
  description = "The subnet ids where the database will be associated."
}

variable "availability_zone" {
  type        = list(any)
  description = "The subnet ids where the database will be associated."
}

variable "db_name" {
  description = "The database instance name."
}

variable "db_username" {
  description = "The database username to assign."
}

variable "db_password" {
  description = "The database password to assign."
}

variable "security_groups" {
  type        = list(any)
  description = "The Seucrity groups in the VPC that the RDS belongs to."
}

resource "aws_db_subnet_group" "devops_and_cloud-subnet_group" {
  name       = "devops_and_cloud-subnet_group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "devops_and_cloud-subnet_group"
  }
}

# resource "aws_db_instance" "petclinic-db" {
#   allocated_storage      = 20
#   db_name                = var.db_name
#   engine                 = "mysql"
#   engine_version         = "5.7"
#   instance_class         = "db.t3.micro"
#   username               = var.db_username
#   password               = var.db_password
#   parameter_group_name   = "default.mysql5.7"
#   skip_final_snapshot    = true
#   vpc_security_group_ids = var.security_groups

#   db_subnet_group_name = aws_db_subnet_group.devops_and_cloud-subnet_group.name
#   availability_zone    = var.availability_zone
# }

# resource "aws_rds_cluster_instance" "cluster_instances" {
#   count                = 3
#   identifier           = "petclinic-rds-cluster-${count.index}"
#   cluster_identifier   = aws_rds_cluster.default.id
#   instance_class       = aws_rds_cluster.default.db_cluster_instance_class
#   engine               = aws_rds_cluster.default.engine
#   engine_version       = aws_rds_cluster.default.engine_version
#   db_subnet_group_name = aws_rds_cluster.default.db_subnet_group_name
# }

resource "aws_rds_cluster" "default" {
  cluster_identifier        = "petclinic-rds-cluster"
  availability_zones        = var.availability_zone
  database_name             = "petclinic"
  master_username           = var.db_username
  master_password           = var.db_password
  engine                    = "mysql"
  engine_version            = "8.0.33"
  allocated_storage         = 100
  storage_type              = "io1"
  iops                      = "1000"
  skip_final_snapshot       = true
  vpc_security_group_ids    = var.security_groups
  db_subnet_group_name      = aws_db_subnet_group.devops_and_cloud-subnet_group.name
  db_cluster_instance_class = "db.m5d.large"
}

output "endpoint_name" {
  value = join(":", [aws_rds_cluster.default.endpoint, aws_rds_cluster.default.port])
}
