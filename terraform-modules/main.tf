provider "aws" {
  region = "us-east-1"
  access_key = "${var.accesskey}"
  secret_key = "${var.secretkey}"
}

module "create_network" {
  source       = "./modules/create_network"
  vpc_create   = true
  vpc_cidr  = "192.20.0.0/24"
  count_subnets   = 2
  vpc_tags  =  "${var.tags}"
  vpc_name  = "first_example"
  az        = ["us-east-1a","us-east-1b" ]
}

module "Security_Group_Web" {
  source       = "./modules/security_groups"
  name         = "sg_per_jenkins"
  description  = "sg for jenkins "
  tags_sg  =  "${var.tags}"
  vpc_id       = "${module.create_network.id_vpc}"
  ingress_cidr = ["${module.create_network.subnet_cidr_blocks}","0.0.0.0/0"]
  #ingress_cidr = ["192.20.0.0/26","192.20.0.64/26"]
  ingress_rules = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    }
  ]

   egress_rules = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"

    }
  ]

}


# Define webserver inside the public subnet
resource "aws_instance" "jenkins_server" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "aws-free"
   subnet_id = "${module.create_network.return_id_subnet}"
   vpc_security_group_ids = ["${module.Security_Group_Web.return_id_sg}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("install_jenkins.sh")}"
}
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${module.Security_Group_Web.return_id_sg}"]
  subnets            = ["${module.create_network.return_id_subnet}"]

  enable_deletion_protection = false

  access_logs {
    bucket  = "foo"
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

