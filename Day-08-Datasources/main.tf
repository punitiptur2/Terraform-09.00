data "aws_subnet" "selected" {
  id = "subnet-090b33f7acab651eb"
}

data "aws_security_group" "selected" {
  id = "sg-0761ee15c40a26bba"
}

resource "aws_instance" "name" {
  ami           = "ami-00e801948462f718a" 
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.selected.id
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  tags = {
    Name = "var.name"
  }
}

