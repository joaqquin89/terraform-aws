variable "accesskey" {
    default  = ""
}

variable "secretkey" {
    default  = ""
}
variable "tags" {
  description = "tags for recognize te proyect"
  default     = {
    owner   ="jjachura"
    proyecto ="only mine"
  }
}
variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "ami" {
  description = "Ubuntu 16.04"
  default = "ami-01e3b8c3a51e88954"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = ""
}
