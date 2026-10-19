terraform {
  required_version = ">= 1.7.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region              = "ap-northeast-2"
  allowed_account_ids = [var.aws_account_id]

  # 기존 실습 정책이 허용하는 태그 키(Name, Project)만 사용합니다.
  default_tags {
    tags = {
      Project = "B3-1"
    }
  }
}
