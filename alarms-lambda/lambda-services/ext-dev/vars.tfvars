#################################
#
#  ZONES
#
#################################

AWS_REGION = "eu-central-1" # TODO - FILL IN
VPC_ID = "vpc-82d33ceb" # init-vpc
SUBNETS = ["subnet-6d44ae04", "subnet-fecbde86", "subnet-05311c4f"] # Private Subnet 1 | Private Subnet 2 | Private Subnet 3
DBG_NAMING_PREFIX = "DBG-DEV-"
KMS_KEY_ID = "arn:aws:kms:eu-central-1:353213619364:key/eab35943-7e9e-4b0c-8de1-de7ac994c59a"



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
TAG_COSTCENTER = "65291006"
ENVIRONMENT = "dev"
DEPLOY_NAME = ""
PRODUCT_NAME = "energy"
