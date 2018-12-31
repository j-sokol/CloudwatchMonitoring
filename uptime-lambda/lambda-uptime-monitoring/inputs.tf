#################################
#
#  ZONES
#
#################################

variable "AWS_REGION" {
  default = "eu-central-1" # TODO - FILL IN
}

variable "KMS_KEY_ID" {
  type = "string"
}

variable "DBG_NAMING_PREFIX" {
  default = "DBG-DEV-"
}

variable "VPC_ID" {
  default = ""
}

variable "SUBNETS" {
  default = []
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
  default = 30
}


variable "CLOUDWATCH_NAMESPACE" {
  default = "EnergyMonitoring/Uptime"
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
  default = "hw120" # TODO - FILL IN / Used to Tag instances, not critical for operating the cluster
}

#################################
#
#  OTHER
#
#################################


variable "AWS_PROVIDER_ASSUME_ROLE" {
  default = "arn:aws:iam::147020635585:role/EnergyDeployment"
}

variable "TAG_PRODUCT" {
  default = "Energy" 
}

variable "TAG_COSTCENTER" {
  default = "65291006"
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