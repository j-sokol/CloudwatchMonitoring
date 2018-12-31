provider "aws" { 
  region = "${var.AWS_REGION}"
  assume_role {
    role_arn = "${var.AWS_PROVIDER_ASSUME_ROLE}"
  }
}


provider "archive" {
  version = "~> 1.0"
}