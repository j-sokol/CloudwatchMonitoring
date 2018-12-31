from moto import *


@mock_ec2
def create_ec2_with_tags(client, ip):
    # ec2 = boto3.client('ec2', region_name='eu-central-1')
    # instances = ec2.run_instances(
    instances = client.run_instances(
        ImageId='ami-123',
        MinCount=1,
        MaxCount=1,
        PrivateIpAddress=ip,
        InstanceType='t2.micro',
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Product',
                        'Value': 'Energy',
                    },
                    {
                        'Key': 'MY_TAG2',
                        'Value': 'MY_VALUE2',
                    },
                ],
            },
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Product',
                        'Value': 'Energy',
                    },
                ]
            },
        ],
    )

@mock_route53
def create_dns_record(client, ip):
    firstzone = conn.create_hosted_zone("testdns.aws.com")
