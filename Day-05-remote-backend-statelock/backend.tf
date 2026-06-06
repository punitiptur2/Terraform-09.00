terraform {
  backend "s3" {
    bucket = "vihanpreddy"
    key = "terraform.tfstate"
    use_lockfile = true #s3 native locking process to prevent concurrent modifications to the state file
    region = "us-east-1"
  }
}

#state lockfile : Terraform acquires a state lock to protect the state from being written by multiple users or processes at the same time. This is crucial for preventing conflicts and ensuring the integrity of the state file. When a user or process initiates an operation that modifies the state, Terraform will attempt to acquire a lock on the state file. If another user or process has already acquired the lock, Terraform will wait until the lock is released before proceeding with the operation. This mechanism