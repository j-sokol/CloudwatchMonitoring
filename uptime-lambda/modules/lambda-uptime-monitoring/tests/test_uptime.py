from uptime.uptime import *
from moto import *
import aresponses
import pytest
import datetime

def test_parse_urls():
    URLS_TO_MONITOR = "https://gitlab.com | https://stallman.org"
    # metrics = collect_metrics(urls=URLS_TO_MONITOR)

    urls =  parse_env_urls(urls=URLS_TO_MONITOR)

    print(urls)

    assert "https://gitlab.com" in urls
    assert "https://stallman.org" in urls


@pytest.mark.asyncio
async def test_async_request(event_loop):
    async with aresponses.ResponsesMockServer(loop=event_loop) as arsps:
        arsps.add(arsps.ANY, '/', 'get', arsps.Response(status=200, text='Running ok.'))

        is_it_up = check_url('http://duckduckgo.com')
        response = await is_it_up

        assert response['status_code'] == 200


def test_create_metric():
    url = "https://foobar.baz"
    report_time = datetime.datetime.utcnow()
    value = 1
    metric = create_cloudwatch_metric(url, report_time, value)
    print(metric)
    assert metric['MetricName'] == 'uptime'
    assert metric['Value'] == 1



@mock_cloudwatch
def test_sending_metrics():
    url = "https://foobar.baz"
    report_time = datetime.datetime.utcnow()
    value = 1
    metric = create_cloudwatch_metric(url, report_time, value)
    session = boto3.Session(region_name='eu-central-1') 
    send_metrics([metric], session=session)


    cloudwatch_client = session.client('cloudwatch')
    metrics = cloudwatch_client.list_metrics()['Metrics']
    print(metrics)

    assert metrics[0]['MetricName'] == 'uptime'

