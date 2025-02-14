variable "region" {
  description = "The region to deploy the resources"
  type = string
  default = "ap-northeast-2"
}

#
## Network
#
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "azs" {
  description = "The availability zones for the subnets"
  type = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "pub_subnet_cidr_blocks" {
  description = "The CIDR blocks for the public subnets"
  type = list(string)
  default = [
    "10.0.100.0/24", 
    "10.0.101.0/24"
  ]
}

variable "priv_subnet_cidr_blocks" {
  description = "The CIDR blocks for the private subnets"
  type = list(string)
  default = [
    "10.0.100.0/24", 
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
}

#
## Security
#

#
## Workloads
#
variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type = string
  default = "t2.micro"
}

#
## DB
#

#
# Common
# 