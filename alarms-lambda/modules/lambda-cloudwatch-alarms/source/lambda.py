# system
import datetime
import sys
import os
import logging
import collections
import ast

# user
import boto3
import json
import requests
from botocore.config import Config
from requests.auth import HTTPBasicAuth
import yaml
import re
import itertools

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

DEBUG = os.environ.get("debug", False)
if DEBUG is not False:
    logging.basicConfig(stream=sys.stdout, level=logging.INFO)


def dict_product(dicts):
    """
    >>> list(dict_product(dict(number=[1,2], character='ab')))
    [{'character': 'a', 'number': 1},
     {'character': 'a', 'number': 2},
     {'character': 'b', 'number': 1},
     {'character': 'b', 'number': 2}]
    """
    return (dict(zip(dicts, x)) for x in itertools.product(*dicts.values()))

def is_in_tags(tags, matching_tag):
    for tag in tags:
        if matching_tag['Key'] in tag['Key'] and matching_tag['Value'] in tag['Value']:
            return True
    return False

def has_all_tags(tags, matching_tags):
    for i in matching_tags:
        if not is_in_tags(tags, i):
            return False
    return True

def dns_matches(domain_name, regexp):
    if re.search(regexp, domain_name):
        return True
    return False    

class CWAlarm(object):

    def __init__(self, metric=None,
                        stat=None,
                        period=None, 
                        namespace=None,
                        eval_period=None, 
                        operator=None, 
                        threshold=None, 
                        alarmAction=None, 
                        dimensions=None, 
                        treat_missing_data='breaching'):
        self.metric=metric
        self.namespace=namespace,
        self.stat=stat
        self.period=period
        self.eval_period=eval_period
        self.operator=operator
        self.threshold=threshold
        self.alarmAction=alarmAction
        self.dimensions=dimensions
        self.treat_missing_data=treat_missing_data

    def __repr__(self):
        return "{} {}".format(str(self.metric), str(self.dimensions))

    

class Alerter(object):
    def __init__(self):
        # Get environment variables
        # self.elasticsearch_url = os.getenv('ELASTICSEARCH_URL', 'http://localhost:9200')
        # self.es_namespace = os.getenv('CLOUDWATCH_NAMESPACE', 'EnergyMonitoring/ElasticSearch')
        self.sns_topic = os.getenv('SNS_TOPIC', '')
        self.aws_region = os.getenv('AWS_REGION', 'eu-central-1')
        self.alert_prefix = os.getenv('ALERT_PREFIX_NAME', 'alert')
        # self.alert_prefix = str("")
        logger.info(self.alert_prefix)
        # self.alert_prefix = 'energy'
        # logger.info(self.alert_prefix)

        self.alarm_action = [os.getenv('TOPIC_ARN', 'arn:aws:sns:REGION:ACCOUNT:SNSTOPIC')]
        self.https_proxy = os.getenv('HTTPS_PROXY', 'localhost:8080')
        self.https_proxy_enabled = os.getenv('HTTPS_PROXY_ENABLED', False)


        # logger.info("alert_prefix", type(self.alert_prefix_name))
        # logger.info("alert_prefix", self.alert_prefix_name)
        logger.info(self.alert_prefix)
        if self.https_proxy_enabled:
            logger.info("proxy enabled:", self.https_proxy_enabled)
        else:
            print("pussy zeman")
        

        # Instances
        self.all_ec2 = {}

        self.mandatory_tag = {'Key': 'Product', 'Value': 'Energy'}
        # Create connection to AWS
        self.session = boto3.Session(region_name=self.aws_region) 
        if self.https_proxy_enabled:
            self.ec2_client  = self.session.client('ec2', 
                                config=Config(proxies={'https': self.https_proxy}))
            self.cloudwatch_client = self.session.client('cloudwatch', 
                                config=Config(proxies={'https': self.https_proxy}))
            self.route53_client  = self.session.client('route53', 
                                config=Config(proxies={'https': self.https_proxy}))
        else:
            self.ec2_client  = self.session.client('ec2')
            self.cloudwatch_client = self.session.client('cloudwatch')
            self.route53_client  = self.session.client('route53')


        # Load configuration file
        with open('config.yaml', 'r') as config_file:
            self.config = yaml.load(config_file)



    def get_already_created_alarms(self):
        # Fetch alarms that are already in cloudwatch
        logger.info("Get alerts")
        logger.info(self.alert_prefix)

        response_cw = self.cloudwatch_client.describe_alarms(AlarmNamePrefix=self.alert_prefix)
        old_cw_alarms = []
        for alarm in response_cw['MetricAlarms']:
            old_cw_alarms.append(alarm['AlarmName'])

        return old_cw_alarms

    def get_aws_region_names(self):
        return [x['RegionName'] for x in self.ec2_client.describe_regions()['Regions']]

    def get_ec2_instances(self):
        self.get_groups()

        region_names = self.get_aws_region_names()

        for region_name in region_names:
            if region_name == self.aws_region:
                for reservation in self.ec2_client.describe_instances()['Reservations']:
                    for instance in reservation['Instances']:
                        for sg in instance.get('SecurityGroups', []):
                            if self.membership[sg['GroupId']] == None:
                                self.membership[sg['GroupId']] = []
                            self.membership[sg['GroupId']].append(('ec2', instance['InstanceId']))
                            

                    if is_in_tags(instance['Tags'], self.mandatory_tag):    
                        self.all_ec2[instance['PrivateIpAddress']] = instance

        self.all_ec2 = self.resolve_ips(self.all_ec2)

        return self.all_ec2


    def get_groups(self):
        self.membership = {}
        self.groups = {}
        self.defaults = {}
        
        region_names = self.get_aws_region_names()

        for region_name in region_names:
            if region_name == self.aws_region:
                for sg in self.ec2_client.describe_security_groups()['SecurityGroups']:
                    if sg['GroupName'] == 'default':
                        self.defaults[sg['GroupId']] = region_name
                    self.membership[sg['GroupId']] = []
                    self.groups[sg['GroupId']] = sg

        return self.groups

    def get_matching_security_group(self, matching_group):
        # Get security group matching `aws_security_group`
        for k, attrs in self.groups.items():        
            if attrs['GroupName'] == matching_group:
                security_group_id = k
                logger.info("Matching group is: {0}, name: {1}".format(k, attrs['GroupName']))
        return security_group_id

    def get_security_group_members(self, security_group_id):
        # Get members of `aws_security_group` security group (aka all the cluster nodes)
        security_group_members = []
        for sg_id, members in self.membership.items():
            if sg_id == security_group_id:
                security_group_members = members
                logger.info("Matching group is: {0}".format(sg_id))

        return security_group_members


    def get_es_nodes(self, matching_group):
        security_group_id = self.get_matching_security_group(matching_group)

        security_group_members = self.get_security_group_members(security_group_id)
        es_nodes = []
        for k, attrs in self.all_ec2.items():
            if ('ec2', attrs['InstanceId']) in security_group_members:
                # Parse node type from it's tags
                for tag in attrs['Tags']:
                    if tag['Key'] == 'Name':
                        node_name = tag['Value']
                node_type = node_name.split('-')[-2]

                # Create all specific names
                node_tag_name = "es-" +  node_type + "-" + attrs['Placement']['AvailabilityZone'] + "-" + attrs['InstanceId']
                node_short_name = node_type + "-" + attrs['InstanceId']
                es_nodes.append({"node_tag_name": node_tag_name, "ip_address": attrs['PrivateIpAddress'], 
                                "node_short_name": node_short_name})

                logger.info("Node tag name: {0}".format(node_tag_name))
                logger.info("Node type: {0}".format(node_type))

        return es_nodes


    def resolve_ips(self, instance_list):
        zones = self.route53_client.list_hosted_zones()

        for z in zones['HostedZones']:
            r = self.route53_client.list_resource_record_sets(HostedZoneId=z['Id'])
            record_sets = r['ResourceRecordSets']

            # Paginate over all results
            while r['IsTruncated'] == True:
                r = self.route53_client.list_resource_record_sets(
                    HostedZoneId=z['Id'],
                    StartRecordName=r['NextRecordName']
                )
                record_sets += r['ResourceRecordSets']

            logger.info("Found the following records: {0}".format(record_sets))
            for r_set in record_sets:
                # Some records might have only meta values
                if 'ResourceRecords' not in r_set:
                    continue

                for record in r_set['ResourceRecords']:
                    if record['Value'] is not None and record['Value'] in instance_list:
                        instance_list[record['Value']]['dns_name'] =  r_set['Name'].strip(".")
        return instance_list


    def get_instance_names(self,hostname_match="*", have_tags=None):
        matching_instances = []
        for inst in self.all_ec2.values():
            if has_all_tags(inst['Tags'], have_tags):
                print("Having instance:", inst['dns_name'])
                if re.search(hostname_match, inst['dns_name']):
                    # print("Matched w/ hostname", inst['dns_name'])
                    matching_instances.append(inst['dns_name'])

        return matching_instances

    def build_alarms(self, config):
        alarms = []
        for alarm in config:
            alarm_dimensions = {}
            for dimension in alarm['dimensions']:
                dimension_name = dimension['name']
                alarm_dimensions[dimension_name] = []
                if dimension['type'] == "static":
                    for val in dimension['value']:
                        alarm_dimensions[dimension_name].append(val)
                if dimension['type'] == "ec2_instances":
                    instances = self.get_instance_names(hostname_match=dimension['dns_search'], have_tags=dimension['has_tags'])
                    alarm_dimensions[dimension_name] = instances
                if dimension['type'] == "has_tag":
                    pass

            dims = []
            for i in dict_product(alarm_dimensions):
                combination = []
                for k,v in i.items():
                    combination.append({"Name": k, "Value": v})
                dims.append(combination)

            # dims = [{"Key": k, "Value": v}  for dim1 in  all_alarm_dim_combinations for k,v in dim1.items()]
            for dim in dims:
                alarms.append(CWAlarm(metric=alarm['alert_metric'],
                                stat=alarm['stat'],
                                namespace=alarm['namespace'],
                                period=alarm['period'], 
                                eval_period=alarm['eval_period'], 
                                operator=alarm['operator'], 
                                threshold=alarm['threshold'], 
                                alarmAction=self.alarm_action, 
                                dimensions=dim, 
                                treat_missing_data='breaching'))

        self.alarms = alarms
    

    def deploy_alarms(self):
        # Generate alarms and send them to cloudwatch
        new_cw_alarms = []
        for alarm in self.alarms:


            # Remove chars [!@#$/:] from alarm name
            alarm_name = re.sub('[!@#$/:]', '', '-'.join([self.alert_prefix, alarm.metric] + [i["Value"] for i in alarm.dimensions]))

            # Send alarm to cloudwatch      
            cw_response = self.cloudwatch_client.put_metric_alarm(
                AlarmName=alarm_name,
                AlarmDescription=str(" - ".join(t['Value'] for t in alarm.dimensions)),
                
                #ActionsEnabled=True|False,
                OKActions=self.alarm_action,
                AlarmActions=self.alarm_action,
                #InsufficientDataActions=['string'],
                MetricName=alarm.metric,
                Namespace=alarm.namespace[0],
                Statistic=alarm.stat,
                #ExtendedStatistic='string',
                Dimensions=alarm.dimensions,
                Period=alarm.period,            
                EvaluationPeriods=alarm.eval_period,
                Threshold=alarm.threshold,
                ComparisonOperator=alarm.operator,
                TreatMissingData=alarm.treat_missing_data
                #EvaluateLowSampleCountPercentile='string'
                )

            logger.info("Created {} alarm, response: {}".format(alarm_name, cw_response)) 
            new_cw_alarms.append(alarm_name)

        return new_cw_alarms


    def delete_alarms(self, alarms):
        # Delete alarms that were not in the new generated set
        for alarm_name in alarms:
            self.cloudwatch_client.delete_alarms(AlarmNames=[alarm_name])
            logger.info("Deleted alarm: {0}".format(alarm_name))


def create_alarms():
    alerter = Alerter()

    old_cw_alarms = alerter.get_already_created_alarms()

    # Get all ec2s in all regions
    all_ec2 = alerter.get_ec2_instances()
    
    # Get all es nodes
    es_security_group = os.getenv('AWS_SECURITY_GROUP', 'sec-energy-elasticsearch-instances')
    es_nodes = alerter.get_es_nodes(es_security_group)
    logger.info("ES nodes are:")
    logger.info(es_nodes)
    print(es_nodes)


    alarms = alerter.build_alarms(alerter.config)
    new_cw_alarms = alerter.deploy_alarms()

    # Difference of alarms already in CW in and newly created ones 
    leftover_alarms = set(old_cw_alarms).difference(set(new_cw_alarms))
    logger.info("Leftover alarms:") 
    logger.info(leftover_alarms)

    alerter.delete_alarms(leftover_alarms)        


def lambda_handler(event, context):
    create_alarms()

if __name__ == '__main__':
    create_alarms()