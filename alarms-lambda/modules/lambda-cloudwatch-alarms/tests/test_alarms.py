from alarms.alarms import *
from moto import *
from helpers import *

def test_match_fn():
    """Test match fn"""
    # Define vars
    domain = "duckduckgo.com"
    regexp = "duck"

    # Run scenario
    assert dns_matches(domain, regexp) == True


@mock_ec2
@mock_route53
def test_get_ec2_instances_with_dns():
    """Test if we get mocked instances with dns assigned"""

    # Define vars
    os.environ["CONFIG_FILE"] = "alarms/config.yaml"
    ip = '192.168.42.5'
    fqdn = "foobar.baz"
    domain = "alerta"

    # Create Alerter object
    alerter  = Alerter()


    # Create mocked resources
    create_ec2_with_tags(alerter.ec2_client, ip)
    create_dns_record(alerter.session, ip, domain, fqdn)


    # Run scenario
    ec2 = alerter.get_ec2_instances()


    assert ec2[ip]['dns_name'] == "{}.{}".format(domain, fqdn)


@mock_ec2
@mock_route53
@mock_cloudwatch
def test_fetching_alarms():

    # Define vars
    os.environ["CONFIG_FILE"] = "alarms/config.yaml"
    ip = '192.168.42.5'
    fqdn = "foobar.baz"
    domain = "alerta"
    alert_prefix = "alert"

    # Create Alerter object
    alerter  = Alerter()

    # Create mocked resources
    create_alarms(alerter.cloudwatch_client, prefix=alert_prefix)


    # Run scenario
    alerts = alerter.get_already_created_alarms()


    assert 'alert-testalarm1' in alerts
    assert 'alert-testalarm2' in alerts


@mock_ec2
@mock_route53
@mock_cloudwatch
def test_adding_alarms():

    # Define vars
    os.environ["CONFIG_FILE"] = "alarms/config.yaml"
    ip = '192.168.42.5'
    fqdn = "foobar.baz"
    domain = "alerta"
    alert_prefix = "alert"

    # Create Alerter object
    alerter  = Alerter()


    # Create mocked resources
    create_alarms(alerter.cloudwatch_client, prefix=alert_prefix)
    create_ec2_with_tags(alerter.ec2_client, ip)
    create_dns_record(alerter.session, ip, domain, fqdn)


    # Run scenario
    all_ec2 = alerter.get_ec2_instances()
    alerts = alerter.build_alarms()
    new_cw_alarms = alerter.deploy_alarms()

    assert 'alert-uptime-httpsstallman.org' in new_cw_alarms

@mock_ec2
@mock_route53
@mock_cloudwatch
def test_adding_alarms():

    # Define vars
    os.environ["CONFIG_FILE"] = "alarms/config.yaml"
    ip = '192.168.42.5'
    fqdn = "foobar.baz"
    domain = "alerta"
    alert_prefix = "alert"

    # Create Alerter object
    alerter  = Alerter()


    # Create mocked resources
    create_alarms(alerter.cloudwatch_client, prefix=alert_prefix)
    create_ec2_with_tags(alerter.ec2_client, ip)
    create_dns_record(alerter.session, ip, domain, fqdn)


    # Run scenario
    old_cw_alarms = alerter.get_already_created_alarms()
    alerter.get_ec2_instances()
    alerter.build_alarms()
    new_cw_alarms = alerter.deploy_alarms()
    leftover_alarms = set(old_cw_alarms).difference(set(new_cw_alarms))
    deleted = alerter.delete_alarms(leftover_alarms)        

    assert 'alert-testalarm1' in deleted
    assert 'alert-testalarm2' in deleted

