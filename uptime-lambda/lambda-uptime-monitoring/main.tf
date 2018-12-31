module "lambda-uptime-monitoring" {
  source                                    = "../modules/lambda-uptime-monitoring"

  AWS_REGION                                = "${var.AWS_REGION}"
  VPC_ID                                    = "${var.VPC_ID}"
  SUBNETS                                   = "${var.SUBNETS}"

  URLS_TO_MONITOR                           = "${var.URLS_TO_MONITOR}"
  TIMEOUT                                   = "${var.TIMEOUT}"
  CLOUDWATCH_NAMESPACE                      = "${var.CLOUDWATCH_NAMESPACE}"
  CLOUDWATCH_CRON                           = "${var.CLOUDWATCH_CRON}"
  PROXY                                     = "${var.PROXY}"

  AWS_PROVIDER_ASSUME_ROLE                  = "${var.AWS_PROVIDER_ASSUME_ROLE}"
  KMS_KEY_ID                                = "${var.KMS_KEY_ID}"
  DBG_NAMING_PREFIX                         = "${var.DBG_NAMING_PREFIX}"
  
  
  TAG_PRODUCT                               = "${var.TAG_PRODUCT}"
  TAG_COSTCENTER                            = "${var.TAG_COSTCENTER}"
  TAG_APPLICATIONID                         = "${var.TAG_APPLICATIONID}"
  TAG_APPLICATION                           = "${var.TAG_APPLICATION}"
  TAG_PROJECT                               = "${var.TAG_PROJECT}"
  TAG_CRITICALITY                           = "${var.TAG_CRITICALITY}"
  TAG_SUPPORT_EMAIL                         = "${var.TAG_SUPPORT_EMAIL}"
  TAG_SUPPORT_SLACK                         = "${var.TAG_SUPPORT_SLACK}"
  TAG_ENVIRONMENT                           = "${var.TAG_ENVIRONMENT}"
  ENVIRONMENT                               = "${var.ENVIRONMENT}"
  DEPLOY_NAME                               = "${var.DEPLOY_NAME}"
  PRODUCT_NAME                              = "${var.PRODUCT_NAME}"
  OWNER                                     = "${var.OWNER}"
}


