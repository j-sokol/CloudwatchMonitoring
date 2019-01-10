# Uptime Lambda

Lambda function that checks various URLs defined in configuration and checks if they are up. 

Webpages are considered up, if return code is one of those:

```
200, 204, 301, 302, 401, 404
```

## How to deploy

Deployment is handled via tool Terraform and make.  From [uptime-lambda](uptime-lambda) directory, run 
```
make init env=ext-dev
```
This will use variables from [ext-dev](lambda-services/ext-dev) directory and will initiate terraform state (state of your cloud infrastructure and will set it as empty). **In `vars.tfvars` you should specify mandatory variables `AWS_REGION`, `VPC_ID`, `SUBNETS`, `KMS_KEY_ID`. All other are not needed.** Also you can change S3 bucket name, where terraform state (tfstate) will be stored, in [backends.tfvars](uptime-lambda/ext-dev/backends.tfvars) file.

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


Which URLs will be monitored can be defined in [ext-dev/vars.tfvars](uptime-lambda/ext-dev/vars.tfvars).

Format is following:
```
URLS_TO_MONITOR = "https://elastic.co | https://grafana.com"
```

You can also specify how often the module will be run - by default it it every minute.
```
CLOUDWATCH_CRON = "rate(1 minute)"
```

## Tests

Tests are included in [tests](modules/lambda-uptime-monitoring/tests) for Alarms lambda. Most of the asyncio requests are mocked using [aresponses](https://github.com/CircleUp/aresponses) library. Tests can be run using command
```
python -m pytest tests/uptime.py
```
from `uptime-lambda/modules/lambda-uptime-monitoring` directory.
