terraform {
  backend "s3" {
    bucket         = "terraform-files-9055"
    key            = "task-1/ec2-fleet/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}