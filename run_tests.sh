#!/bin/bash
set -e

# # https://github.com/travis-ci/travis-ci/issues/7940
# export BOTO_CONFIG=/dev/null

pwd=$PWD
cd alarms-lambda/modules/lambda-cloudwatch-alarms
python -m pytest tests/test_alarms.py

cd $pwd
