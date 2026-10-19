# 모든 run은 mock AWS provider + command=plan입니다. 실제 AWS API를 호출하지 않습니다.
mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }
}

variables {
  aws_account_id = "123456789012"
  ssh_cidr       = "198.51.100.10/32"
  key_pair_name  = "mock-existing-key"
}

run "expected_architecture_and_security" {
  command = plan

  assert {
    condition = (
      aws_vpc.lab.cidr_block == "10.0.0.0/16" &&
      aws_subnet.public.cidr_block == "10.0.1.0/24" &&
      aws_subnet.public.availability_zone == "ap-northeast-2a"
    )
    error_message = "실습 VPC·서브넷·서울 AZ 구성이 달라졌습니다."
  }

  assert {
    condition = (
      !aws_subnet.public.map_public_ip_on_launch &&
      aws_instance.web.associate_public_ip_address
    )
    error_message = "공인 IP는 모든 신규 서버가 아니라 이번 EC2에 명시적으로 할당해야 합니다."
  }

  assert {
    condition = (
      aws_vpc_security_group_ingress_rule.http.cidr_ipv4 == "0.0.0.0/0" &&
      aws_vpc_security_group_ingress_rule.http.ip_protocol == "tcp" &&
      aws_vpc_security_group_ingress_rule.http.from_port == 80 &&
      aws_vpc_security_group_ingress_rule.http.to_port == 80
    )
    error_message = "공개 인바운드는 HTTP TCP 80 규칙이어야 합니다."
  }

  assert {
    condition = (
      aws_vpc_security_group_ingress_rule.ssh.cidr_ipv4 == var.ssh_cidr &&
      aws_vpc_security_group_ingress_rule.ssh.ip_protocol == "tcp" &&
      aws_vpc_security_group_ingress_rule.ssh.from_port == 22 &&
      aws_vpc_security_group_ingress_rule.ssh.to_port == 22
    )
    error_message = "SSH TCP 22는 입력한 단일 IPv4 /32로 제한해야 합니다."
  }

  assert {
    condition = (
      aws_instance.web.instance_type == "t3.micro" &&
      aws_instance.web.credit_specification[0].cpu_credits == "standard" &&
      aws_instance.web.root_block_device[0].volume_type == "gp3" &&
      aws_instance.web.root_block_device[0].volume_size == 8 &&
      aws_instance.web.root_block_device[0].encrypted &&
      aws_instance.web.root_block_device[0].delete_on_termination
    )
    error_message = "EC2 크기·CPU 크레딧·EBS 비용/정리 설정을 확인하세요."
  }

  assert {
    condition = (
      aws_instance.web.metadata_options[0].http_tokens == "required" &&
      aws_instance.web.key_name == var.key_pair_name &&
      aws_instance.web.user_data_replace_on_change
    )
    error_message = "IMDSv2·기존 키 페어·User Data 변경 처리를 확인하세요."
  }

  assert {
    condition = (
      strcontains(file("${path.module}/user-data.sh"), "dnf -y install nginx") &&
      strcontains(file("${path.module}/user-data.sh"), "systemctl enable --now nginx")
    )
    error_message = "Nginx 설치와 서비스 시작 명령이 빠졌습니다. 실제 실행 성공은 별도 검증 대상입니다."
  }
}

run "reject_world_open_ssh" {
  command = plan
  variables {
    ssh_cidr = "0.0.0.0/0"
  }
  expect_failures = [var.ssh_cidr]
}

run "reject_broader_ssh_range" {
  command = plan
  variables {
    ssh_cidr = "198.51.100.0/24"
  }
  expect_failures = [var.ssh_cidr]
}

run "reject_invalid_ipv4" {
  command = plan
  variables {
    ssh_cidr = "999.999.999.999/32"
  }
  expect_failures = [var.ssh_cidr]
}

run "reject_placeholder_key" {
  command = plan
  variables {
    key_pair_name = "REPLACE_WITH_EXISTING_KEY_NAME"
  }
  expect_failures = [var.key_pair_name]
}

run "reject_invalid_account_id" {
  command = plan
  variables {
    aws_account_id = "not-an-account"
  }
  expect_failures = [var.aws_account_id]
}
