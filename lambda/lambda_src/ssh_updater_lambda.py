import requests
import boto3
import os

# Get environment variables
bastion_tag = os.environ.get('DESCRIPTION_TAG', 'gha-bastion-access')
api_url = os.environ.get('GITHUB_META_API_URL', 'https://api.github.com/meta')
script_path = os.environ.get('SCRIPT_PATH', '/opt/scripts/update_iptables.sh')

def lambda_handler(event, context):
    instance_id = get_instance_by_tag(bastion_tag)
    if not instance_id:
        return {
            "status": "error",
            "message": "No bastion instance found with tag"
        }

    github_ips = get_github_ips()
    command = build_command_string(github_ips)
    command_id = send_ssm_command(instance_id, command)
    return {"status": "success", "command_id": command_id}


def get_instance_by_tag(tag_value):
    region = os.environ.get('AWS_REGION')
    ec2 = boto3.client('ec2', region_name=region)
    response = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:Name', 'Values': [tag_value]},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            return instance['InstanceId']
    return None


def get_github_ips():
    response = requests.get(api_url)
    response.raise_for_status()
    return response.json()["actions"]


def build_command_string(ip_list):
    return f"bash {script_path} {' '.join(ip_list)}"  # "bash /opt/scripts/update_iptables.sh 1.2.3.4 5.6.7.8 203.0.11.5"


def send_ssm_command(instance_id, command):
    region = os.environ.get('AWS_REGION')
    ssm = boto3.client("ssm", region_name=region)
    response = ssm.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunShellScript",
        Parameters={"commands": [command]},
    )

    return response["Command"]["CommandId"]
