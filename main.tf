terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "mi_bucket" {
  # Asegúrate de usar un nombre único y válido sin guiones bajos
  bucket        = "fabian-bucket-vcs-2026" 
  force_destroy = true

  tags = {
    Ambiente  = "Dev"
    ManagedBy = "GitHub-VCS-Workflow"
  }
}
