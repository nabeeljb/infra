module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "172.32.0.0/16"
}

module "subnet-public1" {
  source                  = "./modules/subnet"
  cidr_block              = "172.32.1.0/24"
  availability_zone       = "ap-southeast-2a"
  tag_name                = "subnet-public1"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "subnet-public2" {
  source                  = "./modules/subnet"
  cidr_block              = "172.32.2.0/24"
  availability_zone       = "ap-southeast-2b"
  tag_name                = "subnet-public2"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "subnet-private1" {
  source                  = "./modules/subnet"
  cidr_block              = "172.32.3.0/24"
  availability_zone       = "ap-southeast-2a"
  tag_name                = "subnet-private1"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "subnet-private2" {
  source                  = "./modules/subnet"
  cidr_block              = "172.32.4.0/24"
  availability_zone       = "ap-southeast-2b"
  tag_name                = "subnet-private2"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "subnet-secure1" {
  source                  = "./modules/subnet"
  cidr_block              = "172.32.5.0/24"
  availability_zone       = "ap-southeast-2a"
  tag_name                = "subnet-secure1"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "subnet-secure2" {
  source                  = "./modules/subnet"
  cidr_block              = "172.32.6.0/24"
  availability_zone       = "ap-southeast-2b"
  tag_name                = "subnet-secure2"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "subnet-secure3" {
  source                  = "./modules/subnet"
  cidr_block              = "172.32.7.0/24"
  availability_zone       = "ap-southeast-2c"
  tag_name                = "subnet-secure3"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "sg_mysql" {
  source      = "./modules/security_group"
  description = "Security group for AWS RDS Instance."

  vpc_id   = module.vpc.vpc_id
  tag_name = "sg_mysql"

  ingress_port_range  = [3306, 3306]
  ingress_protocol    = "tcp"
  ingress_cidr_blocks = [module.subnet-private1.cidr_block, module.subnet-private2.cidr_block]

  egress_port_range  = [0, 0]
  egress_protocol    = "-1"
  egress_cidr_blocks = [module.subnet-private1.cidr_block, module.subnet-private2.cidr_block]

  depends_on = [module.vpc, module.subnet-private1, module.subnet-private2]
}

module "db" {
  source = "./modules/db"

  subnet_ids        = [module.subnet-secure1.subnet_id, module.subnet-secure2.subnet_id, module.subnet-secure3.subnet_id]
  availability_zone = ["ap-southeast-2a", "ap-southeast-2b"]
  db_name           = "petclinic"
  db_username       = var.DB_USERNAME
  db_password       = var.DB_PASSWORD

  security_groups = [module.sg_mysql.security_group_id]

  depends_on = [module.subnet-secure1, module.subnet-secure2, module.subnet-secure3.subnet_id]
}

module "igw" {
  source   = "./modules/igw"
  vpc_id   = module.vpc.vpc_id
  tag_name = "igw"

  depends_on = [module.vpc]
}

module "route_public_subnet" {
  source = "./modules/routes/public-routes"
  vpc_id = module.vpc.vpc_id
  igw_id = module.igw.igw_id

  tag_name = "route_public_subnet"

  depends_on = [module.igw, module.vpc]
}

module "natgw-private1-subnet" {
  source = "./modules/natgw"

  igw       = module.igw
  subnet_id = module.subnet-public1.subnet_id
  tag_name  = "subnet-private1-natgw"

  depends_on = [module.subnet-public1]
}

module "natgw-private2-subnet" {
  source = "./modules/natgw"

  igw       = module.igw
  subnet_id = module.subnet-public2.subnet_id
  tag_name  = "subnet-private2-natgw"

  depends_on = [module.subnet-public2]
}

module "route_private1_subnet" {
  source = "./modules/routes/private-routes"

  tag_name = "route_private1_subnet"
  vpc_id   = module.vpc.vpc_id
  natgw_id = module.natgw-private1-subnet.natgw_id

  depends_on = [module.vpc, module.natgw-private1-subnet]
}

module "route_private2_subnet" {
  source = "./modules/routes/private-routes"

  tag_name = "route_private2_subnet"
  vpc_id   = module.vpc.vpc_id
  natgw_id = module.natgw-private2-subnet.natgw_id

  depends_on = [module.vpc, module.natgw-private2-subnet]
}

module "routeassociation_subnet_public1" {
  source = "./modules/routes/route-association"

  subnet_id      = module.subnet-public1.subnet_id
  route_table_id = module.route_public_subnet.route_table_id

  depends_on = [module.subnet-public1, module.route_public_subnet]
}

module "routeassociation_subnet_public2" {
  source = "./modules/routes/route-association"

  subnet_id      = module.subnet-public2.subnet_id
  route_table_id = module.route_public_subnet.route_table_id

  depends_on = [module.subnet-public2, module.route_public_subnet]
}

module "routeassociation_subnet_private1" {
  source = "./modules/routes/route-association"

  subnet_id      = module.subnet-private1.subnet_id
  route_table_id = module.route_private1_subnet.aws_route_table_id

  depends_on = [module.subnet-private1, module.natgw-private1-subnet]
}

module "routeassociation_subnet_private2" {
  source = "./modules/routes/route-association"

  subnet_id      = module.subnet-private2.subnet_id
  route_table_id = module.route_private2_subnet.aws_route_table_id

  depends_on = [module.subnet-private2, module.natgw-private1-subnet]
}

module "sg_http" {
  source      = "./modules/security_group"
  description = "Allow HTTP inbound."

  vpc_id   = module.vpc.vpc_id
  tag_name = "sg_http"

  ingress_port_range  = [80, 80]
  ingress_protocol    = "tcp"
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_port_range  = [0, 0]
  egress_protocol    = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]

  depends_on = [module.vpc]
}

module "vpc_endpoint-ssm" {
  source = "./modules/vpc_endpoint"

  tag_name           = "ssm.ap-southeast-2.ssm"
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.ap-southeast-2.ssm"
  subnet_ids         = [module.subnet-private1.subnet_id, module.subnet-private2.subnet_id]
  security_group_ids = [module.sg_http.security_group_id, module.sg_https.security_group_id]

  depends_on = [module.vpc, module.subnet-private1, module.subnet-private2, module.sg_http, module.sg_https]
}

module "vpc_endpoint-ssmmessage" {
  source = "./modules/vpc_endpoint"

  tag_name           = "ssm.ap-southeast-2.ssmmessage"
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.ap-southeast-2.ssmmessages"
  subnet_ids         = [module.subnet-private1.subnet_id, module.subnet-private2.subnet_id]
  security_group_ids = [module.sg_http.security_group_id, module.sg_https.security_group_id]

  depends_on = [module.vpc, module.subnet-private1, module.subnet-private2, module.sg_http, module.sg_https]
}

module "vpc_endpoint-ec2messages" {
  source = "./modules/vpc_endpoint"

  tag_name           = "ssm.ap-southeast-2.ec2message"
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.ap-southeast-2.ec2messages"
  subnet_ids         = [module.subnet-private1.subnet_id, module.subnet-private2.subnet_id]
  security_group_ids = [module.sg_http.security_group_id, module.sg_https.security_group_id]

  depends_on = [module.vpc, module.subnet-private1, module.subnet-private2, module.sg_http, module.sg_https]
}

module "sg_https" {
  source      = "./modules/security_group"
  description = "Allow HTTPS inbound."

  vpc_id   = module.vpc.vpc_id
  tag_name = "sg_https"

  ingress_port_range  = [443, 443]
  ingress_protocol    = "tcp"
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_port_range  = [0, 0]
  egress_protocol    = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]

  depends_on = [module.vpc]
}

module "alb" {
  source = "./modules/alb"

  tag_name = "alb"
  vpc_id   = module.vpc.vpc_id

  security_groups = [module.sg_https.security_group_id]
  subnet_ids      = [module.subnet-public1.subnet_id, module.subnet-public2.subnet_id]

  lb_listener_port         = 443
  lb_listener_protocol     = "HTTPS"
  certificate_arn          = var.CERTIFICATE_ARN
  lb_target_group_port     = 8080
  lb_target_group_protocol = "HTTP"

  depends_on = [module.vpc, module.sg_http, module.subnet-public1, module.subnet-public2]
}

module "sg_petclinic" {
  source      = "./modules/security_group"
  description = "Allow petclinic app inbound."

  vpc_id   = module.vpc.vpc_id
  tag_name = "sg_petclinic"

  ingress_port_range  = [8080, 8080]
  ingress_protocol    = "tcp"
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_port_range  = [0, 0]
  egress_protocol    = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]

  depends_on = [module.vpc]
}

module "launch_config" {
  source = "./modules/ec2"

  name_prefix       = "petclinic-asg-"
  ami_id            = var.AMI_ID
  security_groups   = [module.sg_http.security_group_id, module.sg_https.security_group_id, module.sg_petclinic.security_group_id]
  target_group_arns = [module.alb.lb_target_group.arn]
  subnet_ids        = [module.subnet-private1.subnet_id, module.subnet-private2.subnet_id]

  iam_instance_profile = data.aws_iam_instance_profile.SSMAccesstoEC2.role_name
  user_data_rendered   = data.template_cloudinit_config.deploy_docker.rendered

  depends_on = [module.vpc, module.sg_http, module.sg_https, module.sg_petclinic, module.subnet-private1, module.subnet-private2]
}
