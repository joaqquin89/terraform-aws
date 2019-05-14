provider "aws" {
  region = "us-east-1"
  access_key = "${var.accesskey}"
  secret_key = "${var.secretkey}"
}

module "create_network" {
  source       = "./modules/create_network"
  vpc_create   = false
  vpc_cidr  = "192.20.0.0/24"
  count_subnets   = 2
  vpc_tags  =  "${var.tags}"
  vpc_name  = "first_example"
  az        = ["us-east-1a","us-east-1b" ]
}

module "Security_Group_Web" {
  source       = "./modules/security_groups"
  name         = "sg-k8s"
  description  = "sg for allow traffic between k8s nodes and master "
  tags_sg  =  "${var.tags}"
  vpc_id       =""
  # if you want create a new vpc and subneets , descoment this the next 2 lines
  #vpc_id       = "${module.create_network.id_vpc}"
  #ingress_cidr = ["${module.create_network.subnet_cidr_blocks}","0.0.0.0/0"]
  ingress_cidr = ["192.20.0.0/16"]
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    },
    {
      from_port   = 443
      to_port     = 443
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
resource "aws_instance" "server" {
   count     = "${var.vm_count}"
   ami  = "${var.ami}"
   instance_type = "t3.medium"
   key_name = "${var.key_path}"
   subnet_id="${var.subnet_associate}"
   #Descoment if create the new vpc
   #subnet_id = "${module.create_network.return_id_subnet}"
   vpc_security_group_ids = ["${module.Security_Group_Web.return_id_sg}"]
   associate_public_ip_address = false
   source_dest_check = false
   tags = "${
       merge(var.tags)
    }"
}

resource "aws_elb" "load_balancer" {
  name    = "k8selb"
  subnets=["${var.subnet_associate}"]
  #Descoment if create the new vpc
  #subnets = ["${module.create_network.return_id_subnet}"]
  security_groups    = ["${module.Security_Group_Web.return_id_sg}"]
  instances = ["${aws_instance.server.*.id}"]
  tags = "${merge(var.tags)}"

  listener {
    lb_port           = "80"
    lb_protocol       = "tcp"
    instance_port     = "${var.port_http}"
    instance_protocol = "tcp"
  }

    listener {
    lb_port           = "443"
    lb_protocol       = "tcp"
    instance_port     = "${var.port_https}"
    instance_protocol = "tcp"
  }

    listener {
    lb_port           = "6643"
    lb_protocol       = "tcp"
    instance_port     = "6643"
    instance_protocol = "tcp"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    target              = "HTTP:80/"
  }
}
