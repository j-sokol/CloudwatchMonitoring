from uptime.uptime import *
from moto import *
# from helpers import *



def test_fetch_metrics():
    URLS_TO_MONITOR = "https://gitlab.com | https://stallman.org"
    metrics = collect_metrics(urls=URLS_TO_MONITOR)
    print(metrics)


    assert True == True


# @mock_ec2
# @mock_route53
# @mock_cloudwatch
# def test_adding_alarms():

#     pass
#     # Define vars
#     os.environ["CONFIG_FILE"] = "alarms/config.yaml"
#     ip = '192.168.42.5'
#     fqdn = "foobar.baz"
#     domain = "alerta"
#     alert_prefix = "alert"

#     # Create Alerter object
#     alerter  = Alerter()


#     # Create mocked resources
#     create_alarms(alerter.cloudwatch_client, prefix=alert_prefix)
#     create_ec2_with_tags(alerter.ec2_client, ip)
#     create_dns_record(alerter.session, ip, domain, fqdn)


#     # Run scenario
#     old_cw_alarms = alerter.get_already_created_alarms()
#     alerter.get_ec2_instances()
#     alerter.build_alarms()
#     new_cw_alarms = alerter.deploy_alarms()
#     leftover_alarms = set(old_cw_alarms).difference(set(new_cw_alarms))
#     deleted = alerter.delete_alarms(leftover_alarms)        

#     assert 'alert-testalarm1' in deleted
#     assert 'alert-testalarm2' in deleted

