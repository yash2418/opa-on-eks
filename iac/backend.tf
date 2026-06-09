terraform {
  backend "s3" {
    # These values can be filled in at initialization time
    # Use: terraform init -backend-config="bucket=..." -backend-config="key=..." etc.
    # Or set them here directly
    bucket  = "yash-terraform-statefiles"
    key     = "opa/terraform.tfstate"
    region  = "ap-south-1"
    profile = "devops"

    # IMPORTANT: Uncomment and fill in the values below for remote backend
    # Or run: terraform init -reconfigure -backend-config="bucket=YOUR_BUCKET" ...
  }
}
