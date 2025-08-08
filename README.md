# GitHub Action SSH Bastion
This project automates updating a bastion's iptables for SSH access based on GitHub Actions dynamic IP ranges. Infrastructure is provisioned with Terraform and the update logic runs in AWS Lambda. 

## 🧠 Project Log
I documented every decisions I made/learn while building this project in a Notion Database : [GHA-Bastion](https://lacy-helicopter-80d.notion.site/23c50889ae4f8057add3f3e1646d37fb?v=23c50889ae4f8170a1ce000c9a78277a)

## Package the lambda
run ./package_lambda.sh

## Apply terraform configuration
terraform apply
