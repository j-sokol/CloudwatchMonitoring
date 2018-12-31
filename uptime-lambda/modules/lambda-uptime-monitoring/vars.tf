#################################
#
#  ZONES
#
#################################
variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "DBG_NAMING_PREFIX" {
  default = ""
}

variable "AWS_PROVIDER_ASSUME_ROLE" {
  type = "string"
}

variable "KMS_KEY_ID" {
  type = "string"
}

variable "VPC_ID" {
  default = ""
}

variable "SUBNETS" {
  type = "list"
}


#################################
#
#  LAMBDA
#
#################################

variable "URLS_TO_MONITOR" {
  type = "string"
}

variable "TIMEOUT" {
  type = "string"
}


variable "CLOUDWATCH_NAMESPACE" {
  type = "string"
}

variable "PROXY" {
  default = ""
}

variable "CLOUDWATCH_CRON"{
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