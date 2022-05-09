variable "aws_region" {
  description = "The AWS region where the resources are to be provisioned"
  type        = string
  default     = "eu-central-1"
}

variable "ec2_instance_type" {
  description = "Instance type for the EC2 instances running the L7 Load-Balancing Demo application"
  type        = string
  default     = "t2.nano"
}