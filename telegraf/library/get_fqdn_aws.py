from ansible.module_utils.basic import *
import boto3
import json



def main():
    fields = {
        "ip_address": {"required": True, "type": "str"},
    }

    module = AnsibleModule(argument_spec=fields)
    client = boto3.client('route53')


    zones = client.list_hosted_zones()

    for z in zones['HostedZones']:

        r = client.list_resource_record_sets(HostedZoneId=z['Id'])
        record_sets = r['ResourceRecordSets']

        # Paginate over all results
        while r['IsTruncated'] == True:
            r = client.list_resource_record_sets(HostedZoneId=z['Id'],
                                                StartRecordName=r['NextRecordName'])
            record_sets += r['ResourceRecordSets']


        for r_set in record_sets:
            # Some records might have only meta values
            if 'ResourceRecords' not in r_set:
                continue

            for record in r_set['ResourceRecords']:
                if ip_address in record['Value']:
                    response = {"ansible_fqdn":  r_set['Name'].strip(".")}

    
    module.exit_json(changed=False, meta=response)


if __name__ == '__main__':
    main()

