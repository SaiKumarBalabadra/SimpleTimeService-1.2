# Create the S3 bucket and S3 is capable of state locking feature in newer version.
# before running terraform init with this backend configured.
terraform {
  backend "s3" {
    bucket         = "particle41-tfstate-01" #change this name according to the your bucket name
    key            = "eks/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }
}