terraform {
  backend "s3" {
    bucket = "vihanpreddy"
    key = "terraform.tfstate"
    use_lockfile = true #s3 native locking process to prevent concurrent modifications to the state file
    region = "us-east-1"
  }
}