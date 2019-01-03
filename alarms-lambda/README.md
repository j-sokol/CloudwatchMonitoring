# Alarms Lambda

This module contains two parts - lambda function to create alarms definitons and lambda that ingests messages from SNS topic and sends them to Slack. Communication of functions can be seen in diagram below

```
            +-------------------+
            |Alarms Definition  |
            |(Alarms lambda fn) |
            +-------------------+
                              |
+-------------------------+   |    +-----------   +-----------------+
|          CloudWatch     | <-+    |Amazon SNS|   |Slack message    |
|                         |        |Topic     +-->|(via Slack notify|
|Timeseries DB  ->  Alarms|------->|          |   |Lambda fn)       |
+-------------------------+        +-----------   +-----------------+
```

## How to deploy

Deployment is handled via tool Terraform and make.  From [lambda-services](lambda-services) directory, run 
```
make init env=ext-dev
```
This will use variables from [ext-dev](lambda-services/ext-dev) directory and will initiate terraform state (state of your cloud infrastructure and will set it as empty). **In `vars.tfvars` you should specify mandatory variables `AWS_REGION`, `VPC_ID`, `SUBNETS`, `KMS_KEY_ID`. All other are not needed.** Also you can change S3 bucket name, where terraform state (tfstate) will be stored, in [backends.tfvars](lambda-services/ext-dev/backends.tfvars) file.

After everything set up you can apply the infrastructure to AWS:
```
make apply env=ext-dev
```
NOTE: having infrastructure in cloud will cost you money. After testing is over or you don't need lambda functions anymore, run: 
```
make destroy env=ext-dev
```

**This will only remove lambda functions, but alarms will still stay in CloudWatch. For removing alarms, you need to go to Management console and remove them there.**

## Configuration
### Configuring alarms

Definition of alarms can be changed in configuration file. Format is YAML and can be found in [modules/lambda-cloudwatch-alarms/alarms/config.yaml](modules/lambda-cloudwatch-alarms/alarms/config.yaml). Definition is straight forward and similar to definition in CloudFormation - [link](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cw-alarm.html):
```yaml
- alert_metric: disk_used_percent # Name of metric in CloudWatch
  namespace: "Monitoring/Telegraf" # Namespace in CW where metric is stored
  stat: Average # Statistic in CF
  period: 60 # Period in CF
  eval_period: 5 # EvaluationPeriods in CF
  operator: GreaterThanThreshold
  threshold: 85.0
  dimensions: 
    - type: ec2_instances # Can be on of ec2_instances, static
      name: host # Name of dimension in CW
      dns_search: "elasticsearch-data" # Will return only instances with dns matching elasticsearch-data, "" will return all instances
      has_tags: # Will also filter instance with tags below
        - Key: Application
          Value: energy-monitoring
    - type: static # Will create alarms with all values listed below
      name: device
      value:
       - mapper/vg_elasticsearch_data-lv_elasticsearch_data
```

### Configuring Slack webhook

Webhook url is defined in [ext-dev/vars.tfvars](lambda-services/ext-dev/vars.tfvars).

Format is following:
```
SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/XXXX/XXXX/XXXX"
```


## Tests

Tests are included in [tests](modules/lambda-cloudwatch-alarms/tests) for Alarms lambda. Most of the AWS API requests are mocked using [moto](https://github.com/spulec/moto) library. Tests can be run using command
```
python -m pytest tests/test_alarms.py
```
from `alarms-lambda/modules/lambda-cloudwatch-alarms` directory.
