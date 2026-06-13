variable "ami_id" {
    type = string
    description = "The AMI ID to use for the EC2 instance" # Optional
    default = ""  # Mandatory
    
}
variable "instance_type" {
    description = "The type of instance to use" # Optional
    default = ""  # Mandatory
    
}
variable "name" {
    description = "The name of the EC2 instance" # Optional
    default = ""  # Mandatory
    
}