# aws_region is used for both the provider and as an environment variable for Lambda, so it is defined here for consistency and flexibility.
variable "aws_region" {
  description = "AWS region to deploy resources in. Used for provider and Lambda environment."
  type        = string
  default     = "eu-west-3"
}

variable "ssh_port" {
  description = "Port to allow for SSH access (default 22)."
  type        = number
  default     = 22
}

variable "ami_id" {
  description = "AMI ID for the bastion instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion"
  type        = string
  default     = "t3.micro"
}