variable "create" {
  description = "Whether to create all resources"
  default     = true
}

variable "create_sns_topic" {
  description = "Whether to create new SNS topic"
  default     = true
}

variable "create_with_kms_key" {
  description = "Whether to create resources with KMS encryption"
  default     = false
}

variable "LAMBDA_FUNCTION_NAME" {
  description = "The name of the Lambda function to create"
  default     = "notify_slack"
}

variable "SNS_TOPIC_NAME" {
  description = "The name of the SNS topic to create"
}

variable "SLACK_WEBHOOK_URL" {
  description = "The URL of Slack webhook"
}

variable "SLACK_CHANNEL" {
  description = "The name of the channel in Slack for notifications"
}

variable "SLACK_USERNAME" {
  description = "The username that will appear on Slack messages"
}

variable "SLACK_EMOJI" {
  description = "A custom emoji that will appear on Slack messages"
  default     = ":aws:"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for decrypting slack webhook url"
  default     = ""
}

#################################
#
#  ZONES
#
#################################
variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "AWS_PROVIDER_ASSUME_ROLE" {
  type = "string"
}
variable "DBG_NAMING_PREFIX" {
  default = "DBG-DEV-"
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