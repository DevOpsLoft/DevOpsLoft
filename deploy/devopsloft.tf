terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
  }
}

variable "PROFILE" {
  description = "AWS profile"
}
variable "REGION" {
  description = "AWS region"
}
variable "KEY_NAME" {
  description = "AWS key name"
}
variable "PUBLIC_KEY" {
  description = "AWS public key"
}
variable "SG_NAME" {
  description = "AWS Security Group name"
}
variable "VPC_ID" {
  description = "AWS VPC id"
}
variable "BUCKET" {
  description = "AWS Bucket"
}
variable "DOMAIN_1" {
  description = "SES Domain"
}
variable "DOMAIN_2" {
  description = "SES Domain"
}

provider "aws" {
  profile = var.PROFILE
  region  = var.REGION
}

resource "aws_key_pair" "key" {
  key_name    = var.KEY_NAME
  public_key  = var.PUBLIC_KEY
}

resource "aws_security_group" "security_group" {
  name        = var.SG_NAME
  vpc_id      = var.VPC_ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "elastic_ip" {
  vpc              = true
  public_ipv4_pool = "amazon"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.BUCKET
  acl    = "private"
}

data "aws_iam_policy_document" "task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_role" {
  name = "AmazonECSTaskRole"
  assume_role_policy =  data.aws_iam_policy_document.task-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "S3-attach" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ses-attach" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_ses_domain_identity" "devopsloft" {
  domain = var.DOMAIN_1
}

resource "aws_ses_domain_identity" "lmb" {
  domain = var.DOMAIN_2
}
