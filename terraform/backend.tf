# Create the S3 bucket and DynamoDB table manually (or via a bootstrap script)
# before running terraform init with this backend configured.
terraform {
  backend "s3" {
    bucket         = "particle41-tfstate-01"
    key            = "eks/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = "true"
    encrypt        = true
  }
}