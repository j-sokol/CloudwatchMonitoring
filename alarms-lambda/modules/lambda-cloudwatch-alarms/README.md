# Lambda - Elasticsearch alarms.

Lambda function to create alarms from CloudWatch  metrics gathered of Elasticsearch cluster. 



Alarms description (those values can be changed in lambda.py script):



# Lambda Functions Requirements

To work properly python Lambda functions require all requirements to be 
stored in the directory with the function. To do that, we have to do the following


1. AWS Lambda uses Python3.6. To install on Ubuntu

```
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt install python3.6-dev
```

2. Setup Virtualenv

```
python3.6 -m venv --without-pip elasticsearch-lambda
source test/bin/activate
curl https://bootstrap.pypa.io/get-pip.py | python
deactivate
source test/bin/activate
```

3. Install Requirements

```
pip install -r terraform/modules/lambda-elasticsearch-monitoring/requirements.txt
cd elasticsearch-lambda/lib/python3.6/site-packages 
# Copy the contents of the site-packages directory to terraform/modules/lambda-elasticsearch-monitoring/files
```

