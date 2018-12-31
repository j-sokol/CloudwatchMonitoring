
#################################
#
#  LAMBDA DEPENDECIES
#
#################################
resource "null_resource" "uptime_monitoring_lambda_dependecies" {
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
data "archive_file" "uptime_monitoring_lambda_function" {
  type        = "zip"
  source_dir = "${path.module}/source/deployment"
  output_path = "${path.module}/source/deployment/uptime-monitoring.zip"

  depends_on = ["null_resource.uptime_monitoring_lambda_dependecies"]
}

#################################
#
#  IAM ROLES/POLICIES
#
#################################

resource "aws_iam_role_policy" "iam_role_policy_uptime_monitoring" {
  name = "${var.DBG_NAMING_PREFIX}energy-${var.ENVIRONMENT}-lambda-uptime-monitoring"
  role = "${aws_iam_role.iam_energy_lambda_uptime_monitoring.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["logs:*"],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:CreateGrant"
       ],
       "Resource": [
          "${var.KMS_KEY_ID}"
       ]
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*"
    },
      {
        "Sid": "Stmt1498134382000",
        "Effect": "Allow",
        "Action": [
            "cloudwatch:DescribeAlarms",
            "cloudwatch:ListMetrics",
            "cloudwatch:PutMetricAlarm",
            "cloudwatch:PutMetricData",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "ec2:DescribeSecurityGroups",
            "logs:PutLogEvents",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface"
        ],
        "Resource": [
            "*"
        ]
    }
  ]
}
EOF

lifecycle {
  create_before_destroy = true
}

}


resource "aws_iam_role" "iam_energy_lambda_uptime_monitoring" {
  name = "${var.DBG_NAMING_PREFIX}iam-energy-${var.ENVIRONMENT}-uptime-monitoring"

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

#################################
#
#  SECURITY GROUP
#
#################################
resource "aws_security_group" "lambda_uptime_monitoring" {
  count =  "${var.VPC_ID != "" ? 1 : 0}"
  name        = "sec-${var.TAG_PRODUCT}-lambda-monitoring"
  description = "Allows https from uptime monitoring lambda"
  vpc_id      = "${var.VPC_ID}"
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    self = true
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


#################################
#
#  LAMBDA FUNCTION
#
#################################
resource "aws_lambda_function" "lambda_uptime_monitoring" {
  filename = "${data.archive_file.uptime_monitoring_lambda_function.output_path}"
  source_code_hash = "${data.archive_file.uptime_monitoring_lambda_function.output_base64sha256}"
  function_name = "lambda-energy-${var.ENVIRONMENT}-uptime-monitoring${var.DEPLOY_NAME}"
  description = "Lambda function to monitor URL uptime"
  role = "${aws_iam_role.iam_energy_lambda_uptime_monitoring.arn}"
  handler = "lambda.lambda_handler"
  kms_key_arn = "${var.KMS_KEY_ID}"
  runtime = "python3.6"
  timeout = 60

  # https://www.terraform.io/upgrade-guides/0-11.html#referencing-attributes-from-resources-with-count-0
  vpc_config {
    subnet_ids         = ["${var.SUBNETS}"]
    security_group_ids = ["${element(concat(aws_security_group.lambda_uptime_monitoring.*.id, list("")), 0)}"]
  }   
  environment {
    variables {
      URLS_TO_MONITOR = "${var.URLS_TO_MONITOR}"
      TIMEOUT = "${var.TIMEOUT}"
      CLOUDWATCH_NAMESPACE = "${var.CLOUDWATCH_NAMESPACE}"
      PROXY = "${var.PROXY}"
    }
  }
  tags {
    Name       = "lambda-energy-${var.ENVIRONMENT}-uptime-monitoring${var.DEPLOY_NAME}"
    Owner      = "${var.OWNER}"
    Creator    = "${var.OWNER}"
    Product    = "${var.TAG_PRODUCT}"
    CostCenter = "${var.TAG_COSTCENTER}"
    ApplicationID = "${var.TAG_APPLICATIONID}"
    Application   = "${var.TAG_APPLICATION}"
    Project       = "${var.TAG_PROJECT}"
    Criticality   = "${var.TAG_CRITICALITY}"
    SupportEmail  = "${var.TAG_SUPPORT_EMAIL}"
    SupportSlack  = "${var.TAG_SUPPORT_SLACK}"
    Environment   = "${var.TAG_ENVIRONMENT}"
  }
}

#################################
#
#  CLOUDWATCH EVENTS
#
#################################

resource "aws_cloudwatch_event_rule" "lambda_uptime_monitoring" {
  name = "energy-monitoring-uptime-monitoring"
  description = "Schedule URL uptime check"
  schedule_expression = "${var.CLOUDWATCH_CRON}"
}

resource "aws_cloudwatch_event_target" "lambda_uptime_monitoring_target" {
  rule = "${aws_cloudwatch_event_rule.lambda_uptime_monitoring.name}"
  target_id = "lambda_uptime_monitoring"
  arn = "${aws_lambda_function.lambda_uptime_monitoring.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_uptime_monitoring" {
  statement_id = "allow_cloudwatch_to_call_uptime_monitoring_lambda"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_uptime_monitoring.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.lambda_uptime_monitoring.arn}"
}

