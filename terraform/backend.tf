# Create the S3 bucket and DynamoDB table manually (or via a bootstrap script)
# before running terraform init with this backend configured.
terraform {
  backend "s3" {
    bucket         = "particle41-tfstate"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "particle41-tfstate-lock"
    encrypt        = true
  }
}