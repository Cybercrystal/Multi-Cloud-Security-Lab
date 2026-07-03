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

### Azure
- Resource Group
- Virtual Network + Subnet
- Event Hub Namespace + Event Hub
- Storage Account
- Log Analytics Workspace
- Microsoft Defender for Cloud
- Azure Monitor Diagnostic Settings

## Detection Rules (MITRE ATT&CK Mapped)

| Rule | Tactic | Technique | Severity |
|------|--------|-----------|----------|
| AWS IAM Access Key Created by IAM User | Persistence | T1098 | High |
| AWS Unauthorized API Call - AccessDenied | Defense Evasion | T1078 | Medium |
| AWS Root Account Console Login Detected | Privilege Escalation | T1078.004 | High |
| AWS Security Group Modified | Defense Evasion | T1562.007 | Medium |

## Key Findings
- Live detection alert fired on IAM credential creation event
- CloudTrail → S3 → SQS → Elastic pipeline fully operational
- 500+ CloudTrail events ingested and searchable in Elastic SIEM
- 4 custom detection rules mapped to MITRE ATT&CK framework

## Author
Crystal Branam | Military Veteran | Cybersecurity Engineer  
[GitHub](https://github.com/Cybercrystal) | [LinkedIn](#)
