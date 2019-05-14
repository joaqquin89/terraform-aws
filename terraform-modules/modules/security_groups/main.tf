locals {
  egress_rules_size = "${length( var.egress_rules )}"
  ingress_rules_size = "${length( var.ingress_rules )}"
}

resource "aws_security_group" "dinamyc_sg" {

  name        = "${var.name}"
  description = "${var.description}"
  vpc_id      = "${var.vpc_id}"
  tags = "${merge(map("Name", format("%s", var.name)),var.tags_sg)}"

}

resource "aws_security_group_rule" "ingress_rules" {
  count = "${local.ingress_rules_size}"

  security_group_id = "${aws_security_group.dinamyc_sg.id}"
  type              = "ingress"

  from_port = "${lookup ( var.ingress_rules[count.index],  "from_port" )}"
  to_port = "${lookup ( var.ingress_rules[count.index],  "to_port" )}"
  protocol = "${lookup ( var.ingress_rules[count.index],  "protocol" )}"
  cidr_blocks     = ["${var.ingress_cidr}"]

}

resource "aws_security_group_rule" "egress_rule" {
  count = "${local.egress_rules_size}"

  security_group_id = "${aws_security_group.dinamyc_sg.id}"
  type              = "egress"

  from_port = "${lookup ( var.egress_rules[count.index],  "from_port" )}"
  to_port = "${lookup ( var.egress_rules[count.index],  "to_port" )}"
  protocol = "${lookup ( var.egress_rules[count.index],  "protocol" )}"
  cidr_blocks     = ["${var.ingress_cidr}"]
}