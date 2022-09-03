#######modules/eks/variables.tf

variable "tags" {
  description = "aws-tags"
}

variable "desired_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "vpc_id" {}

variable "cluster_name" {}

variable "endpoint_private_access" {}

variable "endpoint_public_access" {}

variable "public_access_cidrs" {}

variable "node_group_name" {}

variable "scaling_desired_size" {}

variable "scaling_max_size" {}

variable "scaling_min_size" {}

variable "instance_types" {}

variable "public_subnets" {}

variable "private_subnets" {}