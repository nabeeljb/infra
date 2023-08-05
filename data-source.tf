data "aws_ami" "AMI_ID" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "image-id"
    values = [var.AMI_ID]
  }
}

data "template_file" "cloud_init_manifest" {
  template = file("scripts/deploy-petclinic-files.yaml")

  vars = {
    MYSQL_ENDPOINT_NAME = module.db.endpoint_name
  }
}

data "template_cloudinit_config" "deploy_docker" {
  # template = file("../scripts/deploy-petclinic-files.yaml")
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init_manifest.rendered
  }
}

data "aws_iam_instance_profile" "SSMAccesstoEC2" {
  name = "SSMAccesstoEC2"
}
