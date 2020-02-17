# Cloudwatch Monitoring
[![Build Status](https://travis-ci.com/j-sokol/CloudwatchMonitoring.svg?branch=master)](https://travis-ci.com/j-sokol/CloudwatchMonitoring)

Lightweight monitoring solution to notify yourself of statuses of your servers & applications. Currently supports only Slack as an output, but that's easily extensible - can be changed to any other webhook.

Monitoring is built mainly for EC2 (virtual machines on AWS), so on bare metal or other cloud VM providers some features might not work. Also take in mind that some features don't work if you don't have your domain registered in Route53 in AWS.

## How it works

```
+--------------------+                +-------------------+
|Server Metrics      +--------+       |Alarms Definition  |
|(via Telegraf)      |        |       |(Alarms lambda fn) |
+--------------------+        |       +-----------------+-+
                              v                         |
+--------------------+    +-------------------------+   |    +-----------   +-----------------+
|Application Uptime  |    |          CloudWatch     | <-+    |Amazon SNS|   |Slack message    |
|Metrics (Uptime     +--->|                         |        |Topic     +-->|(via Slack notify|
|Lambda fn)          |    |Timeseries DB  ->  Alarms|------->|          |   |Lambda fn)       |
+--------------------+    +-------------------------+        +-----------   +-----------------+
```

- **[System metrics](telegraf)** (such as CPU, memory, application metrics) are handled by **[Telegraf](telegraf/)** gatherer. It is open source client running on virtual machines, with lots of plugins.
- **[Aplication Uptime metrics](uptime-lambda)** are handled via Lambda function sending metrics to Cloudwatch timeseries database.
- **[Alarms Definition](alarms-lambda)** are also created by serverless Python function and then defined in CloudWatch.
- **[Notification output](alarms-lambda)** is currently only Slack, but any other lambda function can read messages from SNS Topic (Queue). This way output to any other services, such as SMS, E-mail, gitter, etc is really easy.

## How to deploy and configure

Parts of the monitoring are deployed and configured separately and described in their respective readmes. (links above)

## Running tests
Before running tests it's recommended to create an python virtual environment. For that you need to have Python v3.6+ installed. Then run:
```
python3 -m venv __venv__
```
and activate it:
```
. ./__venv__/bin/activate
```
All the libraries needed for tests should be installed now. You can do it via pip:
```
pip install -r tests/requirements.txt
```
And finally run the tests:
```
bash run_tests.sh
```
