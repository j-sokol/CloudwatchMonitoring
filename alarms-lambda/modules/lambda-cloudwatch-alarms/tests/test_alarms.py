from alarms.alarms import *


# from moto import mock_cloudwatch
from moto import *

from helpers import *

def test_match_fn():
    """Test match fn"""
    domain = "duckduckgo.com"
    regexp = "duck"

    assert dns_matches(domain, regexp) == True



@mock_ec2
def test_get_ec2_instances():
    """Test match fn"""

    os.environ["CONFIG_FILE"] = "alarms/config.yaml"
    ip = '192.168.42.5'

    alerter  = Alerter()

    create_ec2_with_tags(alerter.ec2_client, ip)

    ec2 = alerter.get_ec2_instances()

    print(len(ec2.values()))

    assert len(ec2) >= 1



@mock_ec2
@mock_route53
def test_get_ec2_instances_with_dns():
    """Test match fn"""

    os.environ["CONFIG_FILE"] = "alarms/config.yaml"
    ip = '192.168.42.5'
    alerter  = Alerter()

    create_ec2_with_tags(alerter.ec2_client, ip)
    ec2 = alerter.get_ec2_instances()

    print(ec2.values())

    assert len(ec2) >= 1
    # assert False == True

# Add mocked dns
# Add mocked alerts
# Check if alerts added
# Check if alerts removed




# def test_create_alerter():
#     """Test match fn"""

#     os.environ["CONFIG_FILE"] = "alarms/config.yaml"
#     alerter  = Alerter()
#     ec2 = alerter.get_ec2_instances()

#     print(ec2)
#     assert False == True
