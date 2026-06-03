terraform {
  backend "s3" {
    bucket = "statebucketdeploy"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}