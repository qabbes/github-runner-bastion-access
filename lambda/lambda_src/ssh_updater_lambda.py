import requests
import boto3


def lambda_handler(event, context):
    # replace with bastion ID or tag
    instance_id = "bastionID"
    github_ips = get_github_ips()
    command = build_command_string(github_ips)
    command_id = send_ssm_command(instance_id, command)
    return {"status": "success", "command_id": command_id}


def get_github_ips():
    response = requests.get("https://api.github.com/meta")
    response.raise_for_status()
    return response.json()["actions"]


def build_command_string(ip_list):
    # Script will be bundled in Lambda deployment package
    script_path = "/var/task/update_iptables.sh"
    return [f"bash {script_path} {' '.join(ip_list)}"]


def send_ssm_command(instance_id, command):
    ssm = boto3.client("ssm")
    response = ssm.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunShellScript",
        Parameters={"commands": [command]},
    )

    return response["Command"]["CommandId"]
