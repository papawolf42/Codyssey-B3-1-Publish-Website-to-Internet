# 첫 Terraform IaC 작성

[코드와 사용법](../infra/terraform/README.md) · [핵심 자원 정의](../infra/terraform/main.tf) · [로컬 검증 기록](0040-terraform-local-validation.md) · [Terraform와 HCL 개념](0038-terraform-opentofu-hcl-쉬운설명.md)

## 이번에 한 것

현재 수동 실습과 같은 목적의 네트워크·EC2·Nginx 구성을 Terraform 코드로 작성했다. 기존 AWS 자원을 수정하거나 이관하지 않았으며, AWS에 실제로 적용하는 일반 plan/apply/destroy는 실행하지 않았다.

- 서울의 VPC·Public Subnet·IGW·Route Table·Security Group·EC2를 선언했다.
- 웹은 80 공개, SSH는 공인 IPv4 한 개의 `/32`만 입력하도록 검증한다.
- 키 페어는 기존 키 이름만 입력한다. 개인키를 생성하거나 HCL/state에 저장하는 자원은 없다.
- User Data로 첫 부팅 때 Nginx를 설치하고 시작하도록 했다.
- 모의 provider 테스트로 실제 AWS 자원에 접근하지 않고 설정과 위험한 입력값 거부를 점검한다.
- 실제 변수·state·계획 파일·개인키·provider 캐시를 Git에서 제외하고 provider 잠금 파일은 보관한다.

## 수동 실습과 다른 점

수동 실습은 VPC 기본 Route Table의 암시적 연결을 확인했다. 이 코드는 전용 테이블을 생성하고 명시적으로 서브넷에 연결한다. EBS 암호화·IMDSv2 필수·표준 CPU 크레딧을 코드에 명시한다. 새로운 구성이므로 기존 실제 자원을 자동으로 관리하게 된 것은 아니다.

## 왜 지금 apply하지 않는가

기존 서버가 실행 중일 수 있어 중복 비용 위험이 있다. 보관 IAM 정책에 provider가 쓰는 일부 작업이 없고, CLI 인증 경로도 아직 검증하지 않았다. 따라서 먼저 기존 자원을 정리하고 재생성할지, 기존 자원 이관을 설계할지 사용자와 결정해야 한다. 별도 승인 없이 권한을 추가하거나 자원을 삭제하지 않는다.

## 무엇을 아직 검증하지 않았는가

실제 AWS API 허용, AMI 조회 결과, 새 EC2 생성, User Data 실행 성공, SSH·내부 HTTP·외부 HTTP·아웃바운드, 실제 종료·삭제는 미검증이다. 기존 수동 서버의 성공 캡처를 이 코드의 배포 성공 증거로 재사용하지 않는다. IaC를 작성했다고 과제의 동작 검증·제출·정리 요구사항이 대체되지는 않는다.

## 읽기 순서

먼저 `main.tf`의 `aws_vpc.lab` 블록을 읽는다. 다음으로 `aws_subnet.public`에서 `vpc_id = aws_vpc.lab.id`가 두 자원의 관계와 의존성을 나타내는지 확인한다. 그 뒤 IGW·라우팅·보안 규칙·EC2·User Data 순으로 한 단계씩 읽는다.
