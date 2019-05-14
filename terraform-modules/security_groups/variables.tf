variable "ingress_rules" {
  type = "list"
  description = "The List of egress Rules"
}
variable "egress_rules" {
  type = "list"
  description = "The List of egress Rules"
}
variable vpc_id {}

variable "ingress_cidr" {
  type = "list"
  description = "The List of Ingress Rules. Each item in the list is a map.  The Maps will be joined with the 'ingress-cidr'"
}
variable name {}
variable description {}