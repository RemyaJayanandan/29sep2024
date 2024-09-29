variable "aws_region" {
  default = "ap-south-1"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  default     = "vpc-0215cff6cab57ccb5"
}

variable "subnet_id" {
  description = "The subnet ID where your EC2 instances will launch"
  default     = "subnet-056c6ccf114ab2079"
}

variable "key_name" {
  description = "The name of the SSH key pair to use for the EC2 instance"
  default     = "aws-keypair"
}
