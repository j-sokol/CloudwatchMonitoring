# Telegraf Role for EC2 instances (currently RHEL6/7 supported)


Deploys a telegraf agent on AWS instances with minimal config, exporting metrics to CloudWatch.

## How to deploy

Deployment is handled via tool ansible. Ansible can be installed from pip and it's recommended to have version >= 2.7.
Steps may be as follows:
```
python3 -m venv __venv__
. ./__venv__/bin/activate
pip install ansible boto3
```
You will need to create your own static inventory, which is described *[here](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)*, or you can use *[dynamic inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#inventory-script-example-aws-ec2)*. In the documentation linked you can also see ec2 dynamic inventory, which works quite well.


And then run the the playbook.
```
ansible-playbook playbooks/telegraf-aws.yml -i *your inventory script*  --limit '*regexp to limit your search to only selected instances*'
``

## Available options


The role has several options that can be enabled in the hosts file.

- telegraf_aws_kapacitor_urls - will monitor the following kapacitor URLs


## How to extend and test 

Defining alarms in Cloudwatch relies on Metric dimensions. At this point, there is no regular expressions support
in Cloudwatch, aka `host="*"`


To simplify our Terraform deployment script, we should try to reduce the dimensions to the absolute bare minimum - ideally 1.

To acomplish this task, in this ansible playbook we rely heavily on `tagexclude` and `fieldpass`, etc.
More information about metric filtering can be found here: 
https://github.com/influxdata/telegraf/blob/master/docs/CONFIGURATION.md#metric-filtering



Before starting telegraf, we should check the dimensions with the following:

```
telegraf -test 
# IDEAL -> results in 1 Dimension host=ubuntu, mem_available_percent=76.36
 mem,host=ubuntu available_percent=76.36401857922485,used_percent=24.747384095672373 1544703931000000000
# IDEAL -> results in 1 Dimension host=ubuntu, kapacitor_num_enabled_tasks=1
> kapacitor,host=ubuntu num_enabled_tasks=1i,num_subscriptions=4i,num_tasks=1i 1544703931000000000

> kapacitor_topics,host=ubuntu,id=cpu collected=0 1544703931000000000

# NOT RECOMMENDED -> results in 2 Dimension host=ubuntu, id= main:metrics_cpu_alert:alert8 kapacitor_topics_collected=1
> kapacitor_topics,host=ubuntu,id=main:metrics_cpu_alert:alert8 collected=0 1544703931000000000

```

