output "subnet_output" {
  description = "The ID of the VPC"
  value       = "${module.create_network.subnet_cidr_blocks}"
}
