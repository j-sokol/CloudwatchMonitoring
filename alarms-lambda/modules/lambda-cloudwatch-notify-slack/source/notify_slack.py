from __future__ import print_function
import os, boto3, json, base64
import urllib.parse
import logging
import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)


# Decrypt encrypted URL with KMS
def decrypt(encrypted_url):
    region = os.environ['AWS_REGION']
    try:
        kms = boto3.client('kms', region_name=region)
        plaintext = kms.decrypt(CiphertextBlob=base64.b64decode(encrypted_url))['Plaintext']
        return plaintext.decode()
    except Exception:
        logging.exception("Failed to decrypt URL with KMS")


def cloudwatch_notification(message, region):
    states = {'OK': 'good', 'INSUFFICIENT_DATA': 'warning', 'ALARM': 'danger'}
    if message['NewStateValue'] == "OK":
        return {
            "color": states[message['NewStateValue']],
                "fallback": "Alarm {} triggered".format(message['AlarmName']),
                "fields": [
                    { "title": message["AlarmName"], "value": message['AlarmDescription'], "short": False},
                    {
                        "title": message['OldStateValue'] + " -> " + message['NewStateValue'],
                        "value": "",
                        "short": False
                    }
                ]
        }
    else:
        return {
                "color": states[message['NewStateValue']],
                "fallback": "Alarm {} triggered".format(message['AlarmName']),
                "fields": [
                    { "title": message["AlarmName"], "value": message['AlarmDescription'], "short": False},
                    {
                        "title": message['OldStateValue'] + " -> " + message['NewStateValue'],
                        "value": message['NewStateReason'] + "   https://console.aws.amazon.com/cloudwatch/home?region=" + region + "#alarm:alarmFilter=ANY;name=" + urllib.parse.quote_plus(message['AlarmName']),
                        "short": False
                    }
                ]
            }


def default_notification(message):
    return {
            "fallback": "A new message",
            "fields": [{"title": "Message", "value": json.dumps(message), "short": False}]
        }


# Send a message to a slack channel
def notify_slack(message, region):
    slack_url = os.environ['SLACK_WEBHOOK_URL']
    if not slack_url.startswith("http"):
        slack_url = decrypt(slack_url)

    slack_channel = os.environ['SLACK_CHANNEL']
    slack_username = os.environ['SLACK_USERNAME']
    SLACK_EMOJI = os.environ['SLACK_EMOJI']

    payload = {
        "channel": slack_channel,
        "username": slack_username,
        "icon_emoji": SLACK_EMOJI,
        "attachments": []
    }
    if "AlarmName" in message:
        notification = cloudwatch_notification(message, region)
        payload['text'] = ""
        # payload['text'] = message["AlarmName"] + "(CloudWatch notification)"
        payload['attachments'].append(notification)
    else:
        payload['text'] = "AWS notification"
        payload['attachments'].append(default_notification(message))

    data = {"payload": json.dumps(payload)}
    # data = urllib.parse.urlencode({"payload": json.dumps(payload)}).encode("utf-8")
    # req = urllib.request.Request(slack_url)
    # urllib.request.urlopen(req, data)
    r = requests.post(slack_url, data=data)
    print(r.status_code)



def lambda_handler(event, context):
    logger.info(event)
    message = json.loads(event['Records'][0]['Sns']['Message'])
    region = event['Records'][0]['Sns']['TopicArn'].split(":")[3]
    notify_slack(message, region)
    return message


if __name__ == '__main__':
    notify_slack({"AlarmName":"Example","AlarmDescription":"Example alarm description.","AWSAccountId":"000000000000","NewStateValue":"ALARM","NewStateReason":"Threshold Crossed","StateChangeTime":"2017-01-12T16:30:42.236+0000","Region":"EU - Ireland","OldStateValue":"OK"}, "eu-west-1")
