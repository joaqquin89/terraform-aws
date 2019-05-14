
output "subnet_cidr_blocks" {
  description = "List of IDs of private subnets"
  value = ["${aws_subnet.subnet_create.*.cidr_block}"]
}

output "return_id_subnet" {
  value = "${element(aws_subnet.subnet_create.*.id, 0)}"
}

output "id_vpc" {
  value = "${aws_vpc.default.id}"
}

output "tags" {
    value="${merge(map("Name", format("%s", var.vpc_name)),var.vpc_tags)}"
}