terraform {
  backend "s3" {
    bucket = "terraform-backend-state-terraform"
    key    = "Terraform/state"
    region = "us-east-1"
    profile = "profile1"
  }
}



