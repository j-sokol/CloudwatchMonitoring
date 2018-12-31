terraform {
  required_version = ">= 0.11"
  backend          "s3"             {}
}

provider "aws" {
  region = "${var.AWS_REGION}"

  assume_role {
    role_arn = "${var.AWS_PROVIDER_ASSUME_ROLE}"
  }
}