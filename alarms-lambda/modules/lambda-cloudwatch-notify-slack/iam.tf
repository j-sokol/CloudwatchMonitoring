data "aws_iam_policy_document" "iam_energy_lambda_slack_notify_assume_role" {
  count = "${var.create}"

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam_energy_lambda_slack_notify_basic" {
  count = "${var.create}"

  statement {
    sid = "AllowWriteToCloudwatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "iam_energy_lambda_slack_notify" {
  count = "${(var.create_with_kms_key == 1 ? 1 : 0) * var.create}"

  source_json = "${data.aws_iam_policy_document.iam_energy_lambda_slack_notify_basic.0.json}"

  statement {
    sid = "AllowKMSDecrypt"

    effect = "Allow"

    actions = ["kms:Decrypt"]

    resources = ["${var.kms_key_arn == "" ? "" : var.kms_key_arn}"]
  }
}

# resource "aws_iam_role" "iam_energy_lambda_slack_notify" {
#   count = "${var.create}"

#   name_prefix        = "lambda"
#   assume_role_policy = "${data.aws_iam_policy_document.iam_energy_lambda_slack_notify_assume_role.0.json}"
# }

resource "aws_iam_role" "iam_energy_lambda_slack_notify" {
  name = "${var.DBG_NAMING_PREFIX}iam-energy-lambda-slack-notify"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  force_detach_policies = true
  lifecycle {
    create_before_destroy = true
  }

}



resource "aws_iam_role_policy" "iam_energy_lambda_slack_notify" {
  count = "${var.create}"

  name_prefix = "iam_energy-lambda-policy-"
  role        = "${aws_iam_role.iam_energy_lambda_slack_notify.0.id}"

  policy = "${element(compact(concat(data.aws_iam_policy_document.iam_energy_lambda_slack_notify.*.json, data.aws_iam_policy_document.iam_energy_lambda_slack_notify_basic.*.json)), 0)}"
}
