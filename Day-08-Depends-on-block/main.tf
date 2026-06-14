resource "aws_instance" "name" {
    ami          = "ami-00e801948462f718a"
    instance_type = "t2.micro"


}

resource "aws_security_group" "name" {
  name        = "terraform-security-group"
  description = "Security group for Terraform EC2 instance"
  vpc_id      = aws_vpc.name.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_s3_bucket" "vihanpreddy" {
  bucket = "vihanpreddy-bucket"
}
resource "aws_s3_bucket_acl" "vihanpreddy_acl" {
  bucket = aws_s3_bucket.vihanpreddy.id
  acl    = "private"
}
