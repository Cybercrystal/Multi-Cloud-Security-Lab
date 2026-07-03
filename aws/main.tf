terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
 }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name    = "multi-cloud-security-lab"
    Project = "threat-detection"
  }
}

# Create a subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name    = "security-lab-subnet"
    Project = "threat-detection"
  }
}

# Create S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "security-lab-cloudtrail-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name    = "cloudtrail-logs"
    Project = "threat-detection"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
# Create CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "security-lab-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  tags = {
    Name    = "security-lab-trail"
    Project = "threat-detection"
  }
}
# S3 Bucket Policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
# IAM policy for Elastic to read CloudTrail logs
resource "aws_iam_policy" "elastic_s3_read" {
  name        = "elastic-cloudtrail-s3-read"
  description = "Allows Elastic Agent to read CloudTrail logs from S3 and SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}",
          "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.cloudtrail.arn
      }
    ]
  })
}
# IAM user for Elastic Agent
resource "aws_iam_user" "elastic_agent" {
  name = "elastic-agent-user"

  tags = {
    Project = "threat-detection"
  }
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "elastic_agent" {
  user       = aws_iam_user.elastic_agent.name
  policy_arn = aws_iam_policy.elastic_s3_read.arn
}

# Create access key for Elastic Agent user
resource "aws_iam_access_key" "elastic_agent" {
  user = aws_iam_user.elastic_agent.name
}

# Output the credentials
output "elastic_agent_access_key" {
  value     = aws_iam_access_key.elastic_agent.id
  sensitive = false
}

output "elastic_agent_secret_key" {
  value     = aws_iam_access_key.elastic_agent.secret
  sensitive = true
}
# Create SQS queue for CloudTrail notifications
resource "aws_sqs_queue" "cloudtrail" {
  name                      = "cloudtrail-logs-queue"
  message_retention_seconds = 86400

  tags = {
    Project = "threat-detection"
  }
}

# S3 bucket notification to SQS
resource "aws_s3_bucket_notification" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  queue {
    queue_arn     = aws_sqs_queue.cloudtrail.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

# SQS policy to allow S3 to send messages
resource "aws_sqs_queue_policy" "cloudtrail" {
  queue_url = aws_sqs_queue.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.cloudtrail.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
          }
        }
      }
    ]
  })
}

# Output SQS queue URL
output "sqs_queue_url" {
  value = aws_sqs_queue.cloudtrail.url
}
