#################################
#
#  LAMBDA DEPENDECIES
#
#################################
resource "null_resource" "cloudwatch_alarms_lambda_dependecies" {
  provisioner "local-exec" {
    command     = "${path.module}/source/install_dependecies.sh"
    interpreter = ["/bin/bash"]
  }
}

#################################
#
#  LAMBDA ZIP
#
#################################
data "archive_file" "cloudwatch_alarms_lambda_function" {
  type        = "zip"
  source_dir  = "${path.module}/source/deployment"
  output_path = "${path.module}/source/deployment/cloudwatch-alarms.zip"

  depends_on  = ["null_resource.cloudwatch_alarms_lambda_dependecies"]
}

#################################
#
#  IAM ROLES/POLICIES
#
#################################

resource "aws_iam_role_policy" "iam_role_policy_cloudwatch_alarms" {
  name   = "${var.DBG_NAMING_PREFIX}energy-lambda-cloudwatch-alarms"
  role   = "${aws_iam_role.iam_energy_lambda_cloudwatch_alarms.id}"

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
      "Action": [ "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeInstances",
            "ec2:DescribeRegions",
            "ec2:DescribeVpcs",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "route53:ListResourceRecordSets",
            "route53:ListHostedZones",
            
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface"],
      "Resource": "*"
    }
  ]
}
EOF

lifecycle {
  create_before_destroy = true
}

}

resource "aws_iam_role_policy" "iam_role_policy_cloudwatch_alarms_ssm" {
  name   = "${var.DBG_NAMING_PREFIX}energy-lambda-cloudwatch-alarms-ssm"
  role   = "${aws_iam_role.iam_energy_lambda_cloudwatch_alarms.id}"

  policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "Action": [
                 "ssm:DescribeParameters"
             ],
             "Resource": "*"
         },
         {
             "Sid": "Stmt1482841904000",
             "Effect": "Allow",
             "Action": [
                 "ssm:GetParameter"
             ],
             "Resource": [
                 "arn:aws:ssm:eu-central-1:${var.ACCOUNT_ID}:parameter/${var.SSM_USERNAME_KEY}",
                 "arn:aws:ssm:eu-central-1:${var.ACCOUNT_ID}:parameter/${var.SSM_PASSWORD_KEY}"
             ]
         },
         {
             "Sid": "Stmt1482841948000",
             "Effect": "Allow",
             "Action": [
                 "kms:Decrypt"
             ],
             "Resource": [
                 "${var.KMS_KEY_ID}"
             ]
         },
         {
            "Sid": "Stmt1498134382000",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:DescribeAlarms",
                "cloudwatch:ListMetrics",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:PutMetricData",
                "cloudwatch:DeleteAlarms"
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

resource "aws_security_group" "sec_energy_cloudwatch_lambda_alarms" {
  name        = "sec-${var.PRODUCT_NAME}-cloudwatch-lambda-alarms"
  description = "Allow https"
  vpc_id      = "${var.VPC_ID}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name       = "sec-${var.PRODUCT_NAME}-cloudwatch-lambda-alarms"
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
    Environment          = "${var.TAG_ENVIRONMENT}"  }
}



resource "aws_iam_role" "iam_energy_lambda_cloudwatch_alarms" {
  name = "${var.DBG_NAMING_PREFIX}iam-energy-cloudwatch-alarms"

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
#  LAMBDA FUNCTION
#
#################################

resource "aws_lambda_function" "lambda_cloudwatch_alarms" {
  filename           = "${data.archive_file.cloudwatch_alarms_lambda_function.output_path}"
  source_code_hash   = "${data.archive_file.cloudwatch_alarms_lambda_function.output_base64sha256}"
  function_name      = "energy-cloudwatch-alarms"
  description        = "Lambda function to create cloudwatch alarms"
  role               = "${aws_iam_role.iam_energy_lambda_cloudwatch_alarms.arn}"
  handler            = "lambda.lambda_handler"
  runtime            = "python3.6"
  timeout            = 300
  environment {
    variables {
      # ELASTICSEARCH_URL            = "https://${var.ELASTIC_SUBDOMAIN}${var.SUBDOMAIN}${var.DOMAIN}"
      TOPIC_ARN                    = "${var.SLACK_TOPIC_ARN}"
      # CLOUDWATCH_NAMESPACE         = "${var.CLOUDWATCH_NAMESPACE}"
      ALERT_PREFIX_NAME = "energy"
      HTTPS_PROXY = "proxy.shrd.dbgcloud.io:3128"
      HTTPS_PROXY_enabled = true

    }
  }
 vpc_config {
    subnet_ids           = ["${var.SUBNETS}"],
    security_group_ids   = ["${aws_security_group.sec_energy_cloudwatch_lambda_alarms.id}" ]  }
  tags {
    Name       = "lambda-energy-${var.TAG_ENVIRONMENT}-cloudwatch-alarms"
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
    Environment          = "${var.TAG_ENVIRONMENT}"  }
}

resource "aws_cloudwatch_event_rule" "lambda_cloudwatch_alarms_schedule" {
  name                 = "energy-monitoring-cloudwatch-alarms-schedule"
  description          = "Schedule cloudwatch metrics pull every 15 minutes"
  schedule_expression  = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_ebs_snapshot_schedule_target" {
  rule             = "${aws_cloudwatch_event_rule.lambda_cloudwatch_alarms_schedule.name}"
  target_id        = "lambda_cloudwatch_alarms"
  arn              = "${aws_lambda_function.lambda_cloudwatch_alarms.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_cloudwatch_alarms" {
  statement_id     = "allow_cloudwatch_to_call_cloudwatch_alarms_lambda"
  action           = "lambda:InvokeFunction"
  function_name    = "${aws_lambda_function.lambda_cloudwatch_alarms.function_name}"
  principal        = "events.amazonaws.com"
  source_arn       = "${aws_cloudwatch_event_rule.lambda_cloudwatch_alarms_schedule.arn}"
}

