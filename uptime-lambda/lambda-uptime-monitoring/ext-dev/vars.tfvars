#################################
#
#  ZONES
#
#################################

AWS_REGION = "eu-central-1" # TODO - FILL IN
DBG_NAMING_PREFIX = ""
KMS_KEY_ID = "arn:aws:kms:eu-central-1:353213619364:key/eab35943-7e9e-4b0c-8de1-de7ac994c59a"

#################################
#
#  LAMBDA
#
#################################

URLS_TO_MONITOR = "https://elastic.co | https://grafana.com"
CLOUDWATCH_CRON = "rate(1 minute)"

#################################
#
#  PERMISSIONS
#
#################################

OWNER = "jan.sokol"

#################################
#
#  OTHER
#
#################################

AWS_PROVIDER_ASSUME_ROLE = ""
TAG_PRODUCT = "Energy" 
TAG_COSTCENTER = "65291006"
TAG_APPLICATIONID = "0"
TAG_APPLICATION = "monitoring"
TAG_PROJECT = "Monitoring"
TAG_CRITICALITY = "Critical"
TAG_SUPPORT_EMAIL = ""
TAG_SUPPORT_SLACK = ""
TAG_ENVIRONMENT = "Production"
ENVIRONMENT = "svc"
DEPLOY_NAME = ""
PRODUCT_NAME = "energy"