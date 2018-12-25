#################################
#
#  ZONES
#
#################################
variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "DBG_NAMING_PREFIX" {
  default = "DBG-DEV-"
}

variable "AWS_PROVIDER_ASSUME_ROLE" {
  type = "string"
}

variable "DOMAIN" {
  type = "string"
}

variable "SUBDOMAIN" {
  type = "string"
}

variable "ELASTIC_SUBDOMAIN" {
  type = "string"
}

variable "SUBNETS" {
  type = "list"
}

variable "VPC_ID" {
  type = "string"
}

#################################
#
#  PERMISSIONS
#
#################################

variable "OWNER" { 
  type = "string"
}

variable "ACCOUNT_ID" { 
  type = "string"
}

variable "KMS_KEY_ID" { 
  type = "string"
}

#################################
#
#  ENVIRONMENTAL VARIABLES
#
#################################

variable "SSM_USERNAME_KEY" { 
  type = "string"
}

variable "SSM_PASSWORD_KEY" { 
  type = "string"
}


#################################
#
#  OTHER
#
#################################

variable "TAG_PRODUCT" {
  type = "string" 
}

variable "TAG_COSTCENTER" {
  type = "string"
}

variable "TAG_APPLICATIONID" {
  type = "string"
}

variable "TAG_APPLICATION" {
  type = "string"
}

variable "TAG_PROJECT" {
  type = "string"
}

variable "TAG_CRITICALITY" {
  type = "string"
}

variable "TAG_SUPPORT_EMAIL" {
  type = "string"
}

variable "TAG_SUPPORT_SLACK" {
  type = "string"
}

variable "TAG_ENVIRONMENT" {
  type = "string"
}

variable "ENVIRONMENT" {
  type = "string"
}
variable "DEPLOY_NAME" {
  type = "string"
}

variable "PRODUCT_NAME" {
  type = "string"
}


#################################
#
#  ALERTS
#
#################################



variable "SLACK_TOPIC_ARN" {
  type = "string"
}

variable "NOTIFY_SLACK_LAMBDA_FUNCTION_NAME" {
  type = "string"
}

variable "CLOUDWATCH_NAMESPACE" {
  type = "string"
}