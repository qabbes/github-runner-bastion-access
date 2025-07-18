# aws_region is used for both the provider and as an environment variable for Lambda, so it is defined here for consistency and flexibility.
variable "aws_region" {
  description = "AWS region to deploy resources in. Used for provider and Lambda environment."
  type        = string
  default     = "eu-west-3"
}

variable "security_group_id" {
  description = "ID of the existing Security Group to update for SSH access."
  type        = string
}

variable "ssh_port" {
  description = "Port to allow for SSH access (default 22)."
  type        = number
  default     = 22
}

