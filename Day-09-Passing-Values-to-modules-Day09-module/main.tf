
module "dev" {
  source = "../Day-09-Modules"
  instance_type = "t2.micro"
  instance_name = "Dev-EC2"
  ami_id = "ami-00e801948462f718a"
  
}
