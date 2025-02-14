variable "region" {
  description = "The region to deploy the resources"
  type = string
  default = "ap-northeast-2"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "pub_subnet_cidr_blocks" {
  description = "The CIDR blocks for the public subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "The availability zones for the subnets"
  type = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

