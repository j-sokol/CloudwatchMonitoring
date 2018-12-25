data "aws_sns_topic" "this" {
  count = "${(1 - var.create_sns_topic) * var.create}"

  name = "${var.SNS_TOPIC_NAME}"
}

resource "aws_sns_topic" "this" {
  count = "${var.create_sns_topic * var.create}"

  name = "${var.SNS_TOPIC_NAME}"
}

locals {
  sns_topic_arn = "${element(compact(concat(aws_sns_topic.this.*.arn, data.aws_sns_topic.this.*.arn, list(""))), 0)}"
}

resource "aws_sns_topic_subscription" "sns_notify_slack" {
  count = "${var.create}"

  topic_arn = "${local.sns_topic_arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.notify_slack.0.arn}"
  
}

resource "aws_lambda_permission" "sns_notify_slack" {
  count = "${var.create}"

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify_slack.0.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${local.sns_topic_arn}"
  
}


#################################
#
#  LAMBDA DEPENDECIES
#
#################################
resource "null_resource" "slack_notify_lambda_dependecies" {
  provisioner "local-exec" {
    command = "${path.module}/source/install_dependecies.sh"
    interpreter = ["/bin/bash"]
  }
}

#################################
#
#  LAMBDA ZIP
#
#################################

data "null_data_source" "lambda_archive" {
  inputs {
    filename = "${substr("${path.module}/source/notify_slack.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "notify_slack" {
  count = "${var.create}"

  type        = "zip"
  source_dir = "${path.module}/source/deployment"
  output_path = "${data.null_data_source.lambda_archive.outputs.filename}"

  depends_on = ["null_resource.slack_notify_lambda_dependecies"]

}

resource "aws_lambda_function" "notify_slack" {
  count = "${var.create}"

  filename = "${data.archive_file.notify_slack.0.output_path}"

  function_name = "${var.LAMBDA_FUNCTION_NAME}"

  role             = "${aws_iam_role.iam_energy_lambda_slack_notify.arn}"
  handler          = "notify_slack.lambda_handler"
  source_code_hash = "${data.archive_file.notify_slack.0.output_base64sha256}"
  runtime          = "python3.6"
  timeout          = 30
  kms_key_arn      = "${var.kms_key_arn}"

  environment {
    variables = {
      SLACK_WEBHOOK_URL = "${var.SLACK_WEBHOOK_URL}"
      SLACK_CHANNEL     = "${var.SLACK_CHANNEL}"
      SLACK_USERNAME    = "${var.SLACK_USERNAME}"
      SLACK_EMOJI       = "${var.SLACK_EMOJI}"
    }
  }

  lifecycle {
    ignore_changes = [
      "filename",
      "last_modified",
    ]
  }
   tags {
    Name = "lambda-energy-${var.TAG_ENVIRONMENT}-notify-slack"
    Owner                = "${var.OWNER}"
    Creator              = "${var.OWNER}"
    Product              = "${var.TAG_PRODUCT}"
    CostCenter           = "${var.TAG_COSTCENTER}"
    ApplicationID        = "${var.TAG_APPLICATIONID}"
    Application          = "${var.TAG_APPLICATION}"
    Project              = "${var.TAG_PROJECT}"
    Criticality          = "${var.TAG_CRITICALITY}"
    SupportEmail         = "${var.TAG_SUPPORT_EMAIL}"
    SupportSlack         = "${var.TAG_SUPPORT_SLACK}"
    Environment          = "${var.TAG_ENVIRONMENT}"
  }
}
