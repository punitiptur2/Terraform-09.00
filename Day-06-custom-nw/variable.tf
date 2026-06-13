variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "" # Default value for the AMI ID, can be overridden by tfvars file or command line variable
}

variable "instance_type" {
  description = "The type of EC2 instance to create"
  type        = string
}

variable "name" {
  description = "The name tag for the EC2 instance"
  type        = string
  default     = "" # Default value for the name tag, can be overridden by tfvars file or command line variable
}

