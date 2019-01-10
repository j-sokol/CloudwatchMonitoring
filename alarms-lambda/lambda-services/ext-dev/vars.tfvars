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
TAG_PRODUCT = "CWMon" 
TAG_COSTCENTER = "dummy"
ENVIRONMENT = "dev"
DEPLOY_NAME = ""
PRODUCT_NAME = "CWMon"
