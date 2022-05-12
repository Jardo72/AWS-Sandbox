variable "aws_region" {
  description = "The AWS region where the resources are to be provisioned"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC (default = 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ec2_instance_type" {
  description = "Instance type for the EC2 instances running the L7 Load-Balancing Demo application"
  type        = string
  default     = "t2.nano"
}

variable "alb_port" {
  description = "TCP port the load balancer will use to accept incoming connections"
  type        = number
  default     = 80
}

variable "ec2_port" {
  description = "TCP port the application instances running on EC2 will use to accept incoming connections"
  type        = number
  default     = 80
}