# system
import datetime
import sys
import os
import logging
import collections

logger = logging.getLogger()
logger.setLevel(logging.INFO)


# user
import boto3
from botocore.config import Config
import asyncio
import aiohttp


class CloudWatchMetricsList(collections.UserList):
    pass

ACCEPTABLE_RESPONSE_CODES = [ 200, 204, 301, 302, 401, 404 ]
aws_region = os.getenv('AWS_REGION', 'eu-central-1')
URLS_TO_MONITOR = os.getenv('URLS_TO_MONITOR', 'https://gitlab.com | https://stallman.org')
TIMEOUT = int(os.getenv('TIMEOUT', 30)) # Enforce str to int conversion
CLOUDWATCH_NAMESPACE = os.getenv('CLOUDWATCH_NAMESPACE', 'Monitoring/Uptime')
PROXY = os.getenv('PROXY', False)


def parse_env_urls(urls=None):    
    """Parses a list of urls
    >>> parse_env_urls(urls='https://kibana.energy.svc.dbg.com | https://grafana.energy.svc.dbg.com')
    ['https://kibana.energy.svc.dbg.com', 'https://grafana.energy.svc.dbg.com']
    """

    urls_list = [] if urls == None else urls.split('|')
    urls_list_stripped = list(map(str.strip, urls_list))

    return urls_list_stripped

async def check_url(url, raise_error=False, loop=None):
    """Function for checking up/down status for an URL

    :param url: URL
    Usage::
    >>> is_it_up = check_url('http://duckduckgo.com')
    [{'url': 'http://duckduckgo.com', 'status_code': 200}]
    """
    logger.info("Checking: {0}".format(url))
    timeout = aiohttp.ClientTimeout(total=TIMEOUT)

    async with aiohttp.ClientSession(loop=loop) as session:
        try:
            async with session.get(url, timeout=timeout) as resp:
                logger.info("{0}: {1}".format(url, resp.status))
                response = {'url': url, 'status_code': resp.status}
        except asyncio.TimeoutError as timeout:
            if raise_error is True:
                logger.info("URL not responding: {0}".format(url))
            response = {'url': url, 'status_code': 503}
        except Exception as e:
            logger.exception("Error encountered when checking: {0} {1}".format(url, e))
            response = {'url': url, 'status_code': 503}

        return response

def check_urls(urls=None):
    """Function for checking up/down status for a list of urls

    :param domain_list: a list of urls
    Usage::
      >>> hosts_list = check_urls(urls=['http://duckduckgo.com'])
    """

    logger.info("Checking {0} domains".format(len(urls)))

    requests = []
    for url in urls:
        requests.append(asyncio.ensure_future(check_url(url)))

    return requests


def gather_requests(urls=None):

    loop = asyncio.get_event_loop()

    requests = check_urls(urls)

    results = loop.run_until_complete(asyncio.gather(*requests))
    logger.info("Collected {0} metrics".format(len(results)))

    return results



def create_cloudwatch_metric(url, report_time, value):
    cw_metric = {
        'MetricName': 'uptime',
        'Dimensions': [
            {
                'Name': 'url',
                'Value': url
            }
        ],
        'Timestamp': report_time,
        'Value': value
    }
    logger.info("Collected metric: {0}".format(cw_metric))
    return cw_metric


def collect_metrics(urls=None):
    metrics = CloudWatchMetricsList()
    urls_list = parse_env_urls(urls=urls)
    results = gather_requests(urls=urls_list)
    
    report_time = datetime.datetime.utcnow()

    for result in results:
        url = result.get('url')
        value = 1 if result.get('status_code') in ACCEPTABLE_RESPONSE_CODES else 0 

        cloudwatch_metric = create_cloudwatch_metric(url, report_time, value)
        metrics.append(cloudwatch_metric)

    return metrics

def send_metrics(cloudwatch_metrics, session=None):

    if session == None:
        session = boto3.Session(region_name=aws_region) 
    if PROXY: 
        cloudwatch_client = session.client('cloudwatch', 
            config=Config(proxies={'https': PROXY})
        )
    else: 
        cloudwatch_client = session.client('cloudwatch')


    cloudwatch_client.put_metric_data(
        Namespace=CLOUDWATCH_NAMESPACE,
        MetricData=cloudwatch_metrics
    )


def lambda_handler(event, handler):
    CloudWatchMetrics = collect_metrics(urls=URLS_TO_MONITOR)

    send_metrics(CloudWatchMetrics)

if __name__ == '__main__':
    metrics = collect_metrics(urls=URLS_TO_MONITOR)
    print(metrics)