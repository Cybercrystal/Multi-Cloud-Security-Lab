# Multi-Cloud Threat Detection Lab

## Overview
A production-grade multi-cloud security lab built to simulate real-world threat detection across AWS and Azure. Infrastructure provisioned entirely with Terraform (IaC). Logs flow from both cloud platforms into a centralized Elastic SIEM where custom detection rules fire alerts mapped to MITRE ATT&CK.

## Architecture 

**AWS Pipeline**
- IAM / EC2 API Calls → CloudTrail (logging) → S3 Bucket (storage) → SQS Queue → Elastic Agent → Elastic SIEM

**Azure Pipeline**
- Azure AD / Resource Activity → Azure Monitor → Event Hub → Elastic Agent → Elastic SIEM

**Detection Layer**
- Elastic SIEM receives logs from both clouds
- Custom KQL detection rules run every 5 minutes
- Alerts mapped to MITRE ATT&CK framework  

## Tools & Technologies
- **Cloud Platforms:** AWS, Azure
- **IaC:** Terraform
- **SIEM:** Elastic Security (Cloud)
- **Log Sources:** AWS CloudTrail, Azure Activity Logs
- **Detection:** Custom KQL rules mapped to MITRE ATT&CK
- **Services:** Microsoft Defender for Cloud, AWS SQS, Azure Event Hub

## Infrastructure Built with Terraform

### AWS
- VPC + Subnet
- S3 Bucket (CloudTrail log storage)
- CloudTrail (multi-region trail)
- SQS Queue (log pipeline notifications)
- IAM User + Policy (least privilege for Elastic Agent)
<img width="1834" height="502" alt="aws-s3-cloudtrail-logs-bucket" src="https://github.com/user-attachments/assets/d69eaaa7-5fb7-4f05-8059-7b3846d6bd53" />
<p><em>S3 bucket receiving CloudTrail logs via Terraform-provisioned pipeline</em></p>

<img width="1830" height="1097" alt="aws-cloudtrail-trail-active" src="https://github.com/user-attachments/assets/09ae333d-9399-4e9a-b442-1d0f1197473e" />
CloudTrail security-lab-trail actively logging with Terraform provisioning event history

<img width="1600" height="346" alt="aws-vpc-terraform-provisioned" src="https://github.com/user-attachments/assets/2ebaaa6c-3ff5-4552-ab38-84c97347ed3b" />
PC multi-cloud-security-lab provisioned via Terraform with dedicated 10.0.0.0/16 CIDR 

<img width="1829" height="369" alt="aws-sqs-cloudtrail-logs-queue" src="https://github.com/user-attachments/assets/263e7f22-c14b-4443-94c7-eaf33f94e7c2" />
SQS queue cloudtrail-logs-queue receiving log notifications from S3

### Azure
- Resource Group
- Virtual Network + Subnet
- Event Hub Namespace + Event Hub
- Storage Account
- Log Analytics Workspace
- Microsoft Defender for Cloud
- Azure Monitor Diagnostic Settings
<img width="1830" height="515" alt="azure-resource-group-multi-cloud-security-lab" src="https://github.com/user-attachments/assets/05367611-762c-4383-901c-3b99cc86e778" />
Azure resource group multi-cloud-security-lab provisioned via Terraform in East US

<img width="1837" height="1207" alt="azure-eventhub-namespace-security-lab" src="https://github.com/user-attachments/assets/01f7fb14-f408-41d2-9acb-da095f96bbe4" />
Event Hub Namespace security-lab-eventhub active with insights-operational-logs hub configured

<img width="1826" height="701" alt="azure-resource-group-resources" src="https://github.com/user-attachments/assets/798d5674-cebc-4159-875e-5e0a16b30782" />
Azure resources: Event Hub Namespace, VNet, Storage Account, and Log Analytics Workspace


## Detection Rules (MITRE ATT&CK Mapped)

| Rule | Tactic | Technique | Severity |
|------|--------|-----------|----------|
| AWS IAM Access Key Created by IAM User | Persistence | T1098 | High |
| AWS Unauthorized API Call - AccessDenied | Defense Evasion | T1078 | Medium |
| AWS Root Account Console Login Detected | Privilege Escalation | T1078.004 | High |
| AWS Security Group Modified | Defense Evasion | T1562.007 | Medium |
<img width="1282" height="951" alt="elastic-detection-rules-all-custom" src="https://github.com/user-attachments/assets/770728fe-3650-4b36-bab9-d0e98cd44ece" />
6 custom KQL detection rules running in Elastic SIEM, all mapped to MITRE ATT&CK

## Key Findings
- Live detection alert fired on IAM credential creation event
- CloudTrail → S3 → SQS → Elastic pipeline fully operational
- 6,000+ CloudTrail events ingested and searchable in Elastic SIEM
- 4 custom detection rules mapped to MITRE ATT&CK framework
<img width="1500" height="751" alt="elastic-iam-key-alert-firing" src="https://github.com/user-attachments/assets/0537cecf-a731-467a-9548-4e8be1b83438" />
Live High severity alert fired on IAM credential creation event (Risk Score 73)

<img width="1274" height="1129" alt="elastic-cloudtrail-6466-docs-ingested" src="https://github.com/user-attachments/assets/6a06796a-6cf5-450d-a37b-66739a8a17fb" />
6,466 CloudTrail documents ingested and searchable in Elastic SIEM

<img width="1261" height="632" alt="elastic-fleet-agents-healthy" src="https://github.com/user-attachments/assets/db1b1a6c-63d2-4126-b2cf-0c9061435e23" />
Elastic Agent healthy and running on Security-Lab-Policy

<img width="876" height="1042" alt="elastic-agent-integrations-aws-azure" src="https://github.com/user-attachments/assets/d626a4d2-6705-47de-941c-2ad42cbb319c" />
WS S3 integration active confirming CloudTrail → SQS → Elastic pipeline

## Author
Crystal Branam | Military Veteran | Cybersecurity Engineer  
[GitHub](https://github.com/Cybercrystal) | [LinkedIn](#)
