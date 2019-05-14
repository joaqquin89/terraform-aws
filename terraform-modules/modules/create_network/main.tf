# Define and create our VPC
resource "aws_vpc" "default" {
  count = "${var.vpc_create ? 1 : 0}"
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags = "${merge(map("Name", format("%s", var.vpc_name)),var.vpc_tags)}"
}

#Create SUBNETS IN THE VPC
resource "aws_subnet" "subnet_create" {
  count = "${ var.count_subnets > 0  ? var.count_subnets : 0}"
  vpc_id = "${ var.vpc_create ? aws_vpc.default.id : var.id_vpc }"
  cidr_block = "${cidrsubnet(var.vpc_cidr, var.count_subnets , count.index)}"
  availability_zone = "${element(var.az, count.index)}"
  tags = "${merge(map("Name", format("%s", var.vpc_name)),var.vpc_tags)}"
}


# DEFINE DE INTERNET GATEWAY ONLY IF  CREATE NEW VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_create ? aws_vpc.default.id : var.id_vpc}"
  tags = "${merge(map("Name", format("%s", var.vpc_name)),var.vpc_tags)}"
}

# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${var.vpc_create ? aws_vpc.default.id : var.id_vpc}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = "${merge(map("Name", format("%s", var.vpc_name)),var.vpc_tags)}"
  depends_on=["aws_internet_gateway.gw"]

}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  count = "${ var.vpc_create && var.count_subnets > 0  ? var.count_subnets : 0}"
  subnet_id = "${element(aws_subnet.subnet_create.*.id, count.index)}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
  depends_on=["aws_route_table.web-public-rt"]
}