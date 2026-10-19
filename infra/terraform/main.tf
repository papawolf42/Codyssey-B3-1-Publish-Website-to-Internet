# AMI는 서울 리전의 Amazon 공식 Amazon Linux 2023 x86_64 중 최신 이미지입니다.
# 최신 이미지가 바뀌면 이후 plan에서 EC2 교체가 제안될 수 있으니 반드시 검토하세요.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-public-subnet"
  }
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# 기본 테이블을 가져다 쓰지 않고 이 코드가 소유할 테이블을 명시적으로 생성합니다.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web"
  description = "Public HTTP; SSH from one learner IPv4 only"
  vpc_id      = aws_vpc.lab.id

  tags = {
    Name = "${var.name_prefix}-web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "Public HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80

  tags = {
    Name = "${var.name_prefix}-http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from learner IPv4 only"
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22

  tags = {
    Name = "${var.name_prefix}-ssh"
  }
}

# 현재 실습처럼 패키지 설치·DNS·외부 접속을 위해 IPv4 아웃바운드를 허용합니다.
# 인바운드 전체 공개라는 뜻은 아니며, 엄격한 최소 출구 정책도 아닙니다.
resource "aws_vpc_security_group_egress_rule" "internet" {
  security_group_id = aws_security_group.web.id
  description       = "Outbound IPv4 for package installation and connectivity"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "${var.name_prefix}-outbound"
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  monitoring                  = false

  user_data                   = file("${path.module}/user-data.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # 서버 초기 설정 전에 인터넷 경로와 보안 규칙의 생성 순서를 보장합니다.
  depends_on = [
    aws_route_table_association.public,
    aws_vpc_security_group_ingress_rule.http,
    aws_vpc_security_group_ingress_rule.ssh,
    aws_vpc_security_group_egress_rule.internet,
  ]

  tags = {
    Name = "${var.name_prefix}-web"
  }

  volume_tags = {
    Name    = "${var.name_prefix}-root"
    Project = "B3-1"
  }
}
