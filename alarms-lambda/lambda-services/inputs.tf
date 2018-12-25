#################################
#
#  ZONES
#
#################################

variable "AWS_REGION" {
  default = "eu-central-1" # TODO - FILL IN
}

variable "VPC_ID" {
  default = "vpc-822970ea" # init-vpc
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

variable "SSM_USERNAME_KEY" {
  type = "string"
}
variable "SSM_PASSWORD_KEY" {
  type = "string"
}
variable "ACCOUNT_ID" {
  type = "string"
}
variable "KMS_KEY_ID" {
  type = "string"
}

variable "SUBNETS" {
  default = ["subnet-5c13f037", "subnet-22ecce58", "subnet-8d08eac0" ] # Private Subnet 1 | Private Subnet 2 | Private Subnet 3
}

variable "DBG_NAMING_PREFIX" {
  description = "Mandatory DBG naming prefix for IAM roles, policies and profiles"
  default     = "DBG-DEV-"
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
  default = "svc"
}

variable "DEPLOY_NAME" {
  type = "string"
}

variable "PRODUCT_NAME" {
  type = "string"
}
variable "SNS_TOPIC_NAME" {
  default = "energy-monitoring-slack-topic"
}

variable "SLACK_CHANNEL" {
  default = "energy_mon_alerts"
}

variable "SLACK_USERNAME" {
  default = "CloudWatch"
}

variable "SLACK_WEBHOOK_URL" {
  default = "https://hooks.slack.com/services/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"
}

variable "LAMBDA_FUNCTION_NAME" {
  default = "energy-monitoring-lambda-slack"
}

variable "CLOUDWATCH_NAMESPACE" {
  default = "EnergyMonitoring/ElasticSearch"
}

variable "ELASTICSEARCH_MONITORING_USER_USERNAME" {
  type = "string"
}


