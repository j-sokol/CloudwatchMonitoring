#!/bin/bash
set -e


pwd=$PWD
cd alarms-lambda/modules/lambda-cloudwatch-alarms
python -m pytest tests/test_alarms.py

cd $pwd
