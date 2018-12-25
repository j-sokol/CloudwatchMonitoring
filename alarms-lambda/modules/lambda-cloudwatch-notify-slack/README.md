# AWS Notify Slack Terraform module

This module creates SNS topic (or use existing one) and a AWS Lambda function which sends notifications to Slack using [incoming webhooks API](https://api.slack.com/incoming-webhooks).

Start by setting up an [incoming webhook integration](https://my.slack.com/services/new/incoming-webhook/) in your Slack workspace.

## Features

- [x] AWS Lambda runtime Python 3.6
- [x] Create new SNS topic or use existing one
- [x] Support plaintext and encrypted version of Slack webhook URL
- [x] Most of Slack message options are customizable
- [x] Support different types of SNS messages:
  - [x] AWS Cloudwatch

## Usage

```hcl
module "lambda-cloudwatch-notify-slack" {
  source                                    = "../modules/lambda-cloudwatch-notify-slack"

  AWS_REGION                                = "${var.AWS_REGION}"
  DBG_NAMING_PREFIX                         = "${var.DBG_NAMING_PREFIX}"
  AWS_PROVIDER_ASSUME_ROLE                  = "${var.AWS_PROVIDER_ASSUME_ROLE}"
  TAG_PRODUCT                               = "${var.TAG_PRODUCT}"
  TAG_COSTCENTER                            = "${var.TAG_COSTCENTER}"
  TAG_ENVIRONMENT                           = "${var.TAG_ENVIRONMENT}"
  DEPLOY_NAME                               = "${var.DEPLOY_NAME}"
  PRODUCT_NAME                              = "${var.PRODUCT_NAME}"
  OWNER                                     = "${var.OWNER}"
  SNS_TOPIC_NAME                            = "${var.SNS_TOPIC_NAME}"
  SLACK_WEBHOOK_URL                         = "${var.SLACK_WEBHOOK_URL}"
  SLACK_CHANNEL                             = "${var.SLACK_CHANNEL}"
  SLACK_USERNAME                            = "${var.SLACK_USERNAME}"
  LAMBDA_FUNCTION_NAME                      = "${var.LAMBDA_FUNCTION_NAME}"
}

```

## Use existing SNS topic or create new

If you want to subscribe AWS Lambda Function created by this module to an existing SNS topic you should specify `create_sns_topic = false` as argument and specify name of existing SNS topic name in `SNS_TOPIC_NAME`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create | Whether to create all resources | string | `true` | no |
| create_sns_topic | Whether to create new SNS topic | string | `true` | no |
| create_with_kms_key | Whether to create resources with KMS encryption | string | `false` | no |
| kms_key_arn | ARN of the KMS key used for decrypting slack webhook url | string | `` | no |
| LAMBDA_FUNCTION_NAME | The name of the Lambda function to create | string | `notify_slack` | no |
| SLACK_CHANNEL | The name of the channel in Slack for notifications | string | - | yes |
| SLACK_EMOJI | A custom emoji that will appear on Slack messages | string | `:aws:` | no |
| SLACK_USERNAME | The username that will appear on Slack messages | string | - | yes |
| SLACK_WEBHOOK_URL | The URL of Slack webhook | string | - | yes |
| SNS_TOPIC_NAME | The name of the SNS topic to create | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| SLACK_LAMBDA_IAM_ROLE_ARN | The ARN of the IAM role used by Lambda function |
| SLACK_LAMBDA_IAM_ROLE_NAME | The name of the IAM role used by Lambda function |
| NOTIFY_SLACK_LAMBDA_FUNCTION_ARN | The ARN of the Lambda function |
| NOTIFY_SLACK_LAMBDA_FUNCTION_INVOKE_ARN | The ARN to be used for invoking Lambda function from API Gateway |
| NOTIFY_SLACK_LAMBDA_FUNCTION_LAST_MODIFIED | The date Lambda function was last modified |
| NOTIFY_SLACK_LAMBDA_FUNCTION_NAME | The name of the Lambda function |
| NOTIFY_SLACK_LAMBDA_FUNCTION_VERSION | Latest published version of your Lambda function |
| SLACK_TOPIC_ARN | The ARN of the SNS topic from which messages will be sent to Slack |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
