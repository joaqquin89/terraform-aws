variable "accesskey" {
    default  = ""
}

variable "secretkey" {
    default  = ""
}
variable "tags" {
  description = "tags for recognize te proyect"
  default     = {
    owner   =""
    proyecto =""
    "kubernetes.io/cluster/k8s-cluster" = "shared"
  }
}
variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-1"
}

variable "subnet_associate" {
  default = "10.10.10.0/24"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "vm_count" {
  default = "4"
}

variable "ami" {
  description = "Ubuntu 16.04"
  default = ""
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "path"
}