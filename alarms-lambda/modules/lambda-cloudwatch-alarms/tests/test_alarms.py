from alarms.alarms import *


# from moto import mock_cloudwatch
from moto import *



def test_match_fn():
    """Test match fn"""
    domain = "duckduckgo.com"
    regexp = "duck"

    assert dns_matches(domain, regexp) == True


def test_create_alerter():
    """Test match fn"""

    os.environ["CONFIG_FILE"] = "alarms/config.yaml"
    alerter  = Alerter()
    ec2 = alerter.get_ec2_instances()

    print(ec2)
    assert False == True


# def test_create_alerter():
#     """Test match fn"""

#     os.environ["CONFIG_FILE"] = "alarms/config.yaml"
#     alerter  = Alerter()
#     ec2 = alerter.get_ec2_instances()

#     print(ec2)
#     assert False == True
