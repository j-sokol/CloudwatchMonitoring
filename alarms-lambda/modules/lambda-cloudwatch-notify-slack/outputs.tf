output "SLACK_TOPIC_ARN" {
  description = "The ARN of the SNS topic from which messages will be sent to Slack"
  value       = "${local.sns_topic_arn}"
}

output "SLACK_LAMBDA_IAM_ROLE_ARN" {
  description = "The ARN of the IAM role used by Lambda function"
  value       = "${element(concat(aws_iam_role.iam_energy_lambda_slack_notify.*.arn, list("")), 0)}"
}

output "SLACK_LAMBDA_IAM_ROLE_NAME" {
  description = "The name of the IAM role used by Lambda function"
  value       = "${element(concat(aws_iam_role.iam_energy_lambda_slack_notify.*.arn, list("")), 0)}"
}

output "NOTIFY_SLACK_LAMBDA_FUNCTION_ARN" {
  description = "The ARN of the Lambda function"
  value       = "${element(concat(aws_lambda_function.notify_slack.*.arn, list("")), 0)}"
}

output "NOTIFY_SLACK_LAMBDA_FUNCTION_NAME" {
  description = "The name of the Lambda function"
  value       = "${element(concat(aws_lambda_function.notify_slack.*.function_name, list("")), 0)}"
}

output "NOTIFY_SLACK_LAMBDA_FUNCTION_INVOKE_ARN" {
  description = "The ARN to be used for invoking Lambda function from API Gateway"
  value       = "${element(concat(aws_lambda_function.notify_slack.*.invoke_arn, list("")), 0)}"
}

output "NOTIFY_SLACK_LAMBDA_FUNCTION_LAST_MODIFIED" {
  description = "The date Lambda function was last modified"
  value       = "${element(concat(aws_lambda_function.notify_slack.*.last_modified, list("")), 0)}"
}

output "NOTIFY_SLACK_LAMBDA_FUNCTION_VERSION" {
  description = "Latest published version of your Lambda function"
  value       = "${element(concat(aws_lambda_function.notify_slack.*.version, list("")), 0)}"
}
