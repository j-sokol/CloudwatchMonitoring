#!/bin/bash
set -e

# Run Alarm tests
pwd=$PWD
cd alarms-lambda/modules/lambda-cloudwatch-alarms
python -m pytest tests/test_alarms.py


# Run Uptime monitoring tests
cd $pwd
cd uptime-lambda/modules/lambda-uptime-monitoring
python -m pytest tests/test_uptime.py


cd $pwd