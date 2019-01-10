#################################
#
#  ZONES
#
#################################

AWS_REGION = "eu-central-1" # TODO - FILL IN
VPC_ID = "vpc-1337" # init-vpc
SUBNETS = ["subnet-1337", "subnet-1338", "subnet-1339"] # Private Subnet 1 | Private Subnet 2 | Private Subnet 3
DBG_NAMING_PREFIX = "DEV-"
KMS_KEY_ID = "arn:aws:kms:eu-central-1:1337:key/xx-xx-x-xx-xx"



#################################
#
#  PERMISSIONS
#
#################################

OWNER = "jan.sokol" # TODO - FILL IN / Used to Tag instances, not critical for operating the cluster

#################################
#
#  OTHER
#
#################################
AWS_PROVIDER_ASSUME_ROLE = ""
TAG_PRODUCT = "Energy" 
TAG_COSTCENTER = ""
TAG_APPLICATIONID = "0"
TAG_APPLICATION = "monitoring"
TAG_PROJECT = "Monitoring"
TAG_CRITICALITY = "Critical"
TAG_SUPPORT_EMAIL = ""
TAG_SUPPORT_SLACK = ""
TAG_ENVIRONMENT = ""
ENVIRONMENT = "svc"
DEPLOY_NAME = ""
PRODUCT_NAME = ""

URLS_TO_MONITOR = "https://elastic.co | https://grafana.com"
CLOUDWATCH_CRON = "rate(1 minute)"

