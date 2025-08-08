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
  default     = "ami-0c02fb55956c7d316"  # Amazon Linux 2 in eu-west-3
}

variable "instance_type" {
  description = "Instance type for the bastion"
  type        = string
  default     = "t3.micro"
}

variable "script_directory" {
  description = "Directory path on the EC2 instance where scripts will be stored"
  type        = string
  default     = "/opt/scripts"
}

variable "update_iptables_script_name" {
  description = "Name of the iptables update script"
  type        = string
  default     = "update_iptables.sh"
}

variable "github_meta_api_url" {
  description = "GitHub API endpoint to fetch GitHub Actions IP ranges"
  type        = string
  default     = "https://api.github.com/meta"
}