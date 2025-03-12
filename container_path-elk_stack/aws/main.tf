provider "aws" {
  region = "us-east-2"
}

## Placing this here for use later. For now I want to use my local directory for tf state
# terraform {
#   backend "s3" {
#     bucket         = "my-bucket-name-here"
#     key            = "ecs/elk/terraform.tfstate"
#     region         = "us-east-2"
#     encrypt        = true
#   }
# }