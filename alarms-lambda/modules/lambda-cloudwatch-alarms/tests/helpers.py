from moto import *


@mock_ec2
def create_ec2_with_tags(client, ip):
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
def create_dns_record(session, ip, dns, fqdn):
    conn = session.client('route53', region_name='eu-central-1')
    conn.create_hosted_zone(
        Name="{}.".format(fqdn),
        CallerReference=str(hash('foo')),
        HostedZoneConfig=dict(
            PrivateZone=True,
            Comment="{}".format(fqdn),
        )
    )

    zones = conn.list_hosted_zones_by_name(DNSName="{}.".format(fqdn))

    hosted_zone_id = zones["HostedZones"][0]["Id"]

    # Create A Record.
    a_record_endpoint_payload = {
        'Comment': 'create A record {}.{}'.format(dns, fqdn),
        'Changes': [
            {
                'Action': 'CREATE',
                'ResourceRecordSet': {
                    'Name': '{}.{}.'.format(dns, fqdn),
                    'Type': 'A',
                    'TTL': 10,
                    'ResourceRecords': [{
                        'Value': ip
                    }]
                }
            }
        ]
    }
    conn.change_resource_record_sets(HostedZoneId=hosted_zone_id, ChangeBatch=a_record_endpoint_payload)



@mock_cloudwatch
def create_alarms(client, prefix="alert"):
    # client = boto3.client('cloudwatch', region_name='eu-central-1')

    client.put_metric_alarm(
        AlarmName='{}-testalarm1'.format(prefix),
        MetricName='cpu',
        Namespace='blah',
        Period=10,
        EvaluationPeriods=5,
        Statistic='Average',
        Threshold=2,
        ComparisonOperator='GreaterThanThreshold',
    )
    client.put_metric_alarm(
        AlarmName='{}-testalarm2'.format(prefix),
        MetricName='cpu',
        Namespace='blah',
        Period=10,
        EvaluationPeriods=5,
        Statistic='Average',
        Threshold=2,
        ComparisonOperator='GreaterThanThreshold',
    )

    resp = client.describe_alarms(
        # StateValue='ALARM'
    )
    print(resp)
