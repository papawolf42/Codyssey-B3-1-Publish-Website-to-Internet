# B3-1 Terraform 학습용 구성

[과제 명세](../../docs/0051-requirements-and-review-reference.md) · [수동으로 완료한 실제 배포 기록](../../docs/0025-ec2-deployment-walkthrough.md)

## 현재 상태와 안전 경계

**이 코드는 아직 AWS에 적용하지 않았습니다.** 기존 VPC·EC2를 가져오거나 수정하는 코드가 아니라, 승인 후 별도 새 스택을 만드는 학습용 작성본입니다. 같은 이름이나 CIDR을 적어도 기존 자원과 자동 연결되지 않습니다.

루트 README의 SSH·HTTP 성공 증빙은 기존 수동 서버의 결과입니다. 이 Terraform 구성의 실제 배포·User Data 실행·외부 접속 성공을 검증한 결과가 아닙니다.

현재 서버를 둔 채 적용하면 EC2가 추가되어 과제의 1대 구성과 달라지고 비용도 늘 수 있습니다. 먼저 **기존 자원 정리 후 새로 만들지 / 기존 자원을 import할지**를 결정해야 합니다. 이 작성본에는 import나 자동 apply/destroy를 넣지 않았습니다.

## 만드는 구성

- 서울 리전 `ap-northeast-2`, AZ `ap-northeast-2a`.
- VPC `10.0.0.0/16`, Public Subnet `10.0.1.0/24`.
- IGW, `0.0.0.0/0 → IGW` 경로를 가진 전용 Route Table, 명시적 서브넷 연결.
- Security Group: HTTP TCP 80은 `0.0.0.0/0`, SSH TCP 22는 입력한 공인 IPv4 `/32`만 허용.
- IPv4 아웃바운드는 패키지 설치·DNS·외부 통신을 위해 전체 허용. 이는 엄격한 최소 출구 정책이 아닙니다.
- Amazon 공식 Amazon Linux 2023 x86_64 AMI, `t3.micro`, 표준 CPU 크레딧.
- 암호화된 gp3 8 GiB 루트 볼륨, 인스턴스 종료 시 루트 볼륨 삭제 설정.
- IMDSv2 필수, 기존 EC2 키 페어 사용.
- User Data로 Nginx 설치, 실행, 자동 시작 등록, localhost HTTP 성공 확인.

관리 대상은 10개 Terraform resource입니다. AMI 조회는 data source이며 별도 자원을 생성하지 않습니다. 키 페어·IAM·EIP·NAT Gateway·ALB·RDS·S3·공유 파일 시스템은 생성하지 않습니다. 연결된 키 페어를 Terraform이 소유하거나 삭제하지 않습니다.

현재 수동 구성은 기본 Route Table의 암시적 연결을 사용했습니다. 이 코드는 관리 범위를 분명히 하기 위해 전용 테이블과 명시적 연결을 사용하므로 동작 목적은 같지만 자원 구조가 완전히 동일하지는 않습니다.

## 파일을 읽는 순서

1. `versions.tf`: Terraform/provider 버전, 서울 리전, 계정 ID 제한.
2. `variables.tf`: 입력값과 SSH `/32` 검증.
3. `main.tf`: 네트워크 → 보안 규칙 → 서버와 의존성.
4. `user-data.sh`: 서버 첫 부팅 시 Nginx 초기 설정.
5. `outputs.tf`: 새 IP·접속 주소·SSH 명령 예시·정리용 자원 ID.
6. `tests/safety.tftest.hcl`: 실제 AWS가 아닌 mock provider로 실행하는 안전성 테스트.
7. `.terraform.lock.hcl`: 검증 시 선택한 provider 버전과 체크섬. Git에 함께 보관합니다.

## 로컬 검증만 하기

Terraform 1.7 이상, 2.0 미만이 필요합니다. 일반 터미널에서 아래 명령은 저장소 루트 기준입니다.

```powershell
terraform -chdir=infra/terraform fmt -check -recursive
terraform -chdir=infra/terraform init -backend=false -input=false
terraform -chdir=infra/terraform validate
terraform -chdir=infra/terraform test
```

`init`은 Terraform Registry 등에서 provider를 다운로드할 수 있지만, 이 구성에서 AWS 자원을 만들거나 조회하는 단계는 아닙니다. 테스트의 모든 run은 `mock_provider "aws"`와 `command = plan`을 사용합니다. **일반 `terraform plan`과 달리 이 모의 테스트는 AWS 계정 자원 API를 호출하지 않으며 실제 인증도 필요하지 않습니다.**

검증 결과는 [로컬 검증 기록](../../docs/0040-terraform-local-validation.md)을 참고하세요. 실제 클라우드 실행이나 IAM 허용 여부까지 검증한 것은 아닙니다.

## 실제 배포 전 확인할 것

다음 절차는 안내이며 아직 실행하지 않았습니다. plan도 AWS 조회를 수행할 수 있으므로 사용자 확인과 IAM 검토 후 진행합니다.

1. 기존 스택과의 관계, 추가 비용, 관리 대상과 삭제 대상을 먼저 결정합니다.
2. 별도 최소권한 IAM 신원으로 사용할 CLI 인증 경로를 확인합니다. 콘솔 로그인만 되어 있다고 Terraform도 인증되는 것은 아닙니다. 키 발급이나 관리자 권한 추가를 자동으로 진행하지 않습니다.
3. `terraform.tfvars.example`을 `terraform.tfvars`로 복사하고 계정 ID·현재 공인 IPv4 `/32`·기존 키 페어 이름을 입력합니다. 키 이름은 개인키 경로나 키 내용이 아닙니다.
4. 승인 후 일반 `terraform init`, `terraform plan -out=reviewed.tfplan`으로 계획을 확인합니다.
5. 대상 계정·리전·생성/교체/삭제 목록과 비용을 확인하고 별도 승인 후 `terraform apply reviewed.tfplan`을 실행합니다. `-auto-approve`는 사용하지 않습니다.
6. 출력된 IP는 EC2 생성 결과일 뿐 Nginx 초기 설정 완료 보증이 아닙니다. 아래 실제 검증을 수행합니다.

각 명령을 이 폴더에서 실행하거나 `-chdir=infra/terraform` 옵션을 사용하세요. plan 파일·state·실제 tfvars·개인키는 Git에 올리지 않습니다. 저장소의 로컬 `.gitignore`와 이 폴더의 `.gitignore`에 제외 규칙을 추가했습니다. 이 폴더의 `.gitignore`도 코드와 함께 보관해 다른 PC에서도 보호 규칙을 유지하세요. AWS 자격증명을 HCL·User Data·tfvars에 직접 넣지 않습니다.

### 현재 IAM 정책과의 차이

보관된 실습 정책을 그대로 사용하면 성공한다고 보장할 수 없습니다. 아래는 추가 검토가 필요한 작업의 예시이며 완성된 추가 권한 목록이 아닙니다.

- VPC DNS 속성 조회·변경: `ec2:DescribeVpcAttribute`, `ec2:ModifyVpcAttribute`.
- SG 기본 아웃바운드 제거와 새 규칙 관리: `ec2:AuthorizeSecurityGroupEgress`, `ec2:RevokeSecurityGroupEgress`, `ec2:RevokeSecurityGroupIngress`, 변경 시 `ec2:ModifySecurityGroupRules` 등.
- EC2 세부 속성·CPU 크레딧 조회/변경: `ec2:DescribeInstanceAttribute`, `ec2:DescribeInstanceCreditSpecifications`, `ec2:ModifyInstanceCreditSpecification` 등.
- 태그 수정/제거 시 `ec2:DeleteTags` 등.
- 루트 볼륨 암호화와 계정의 KMS 정책·조직 정책 조건도 실제 실행 전에 검토합니다.

정확한 추가 권한은 해당 provider 버전의 동작과 오류 근거로 좁혀야 합니다. 서울 리전·계정·실습 자원 범위를 유지하고, 이 때문에 `AdministratorAccess`나 무관한 서비스 전체 권한을 붙이지 않습니다. 현재 IAM 정책을 이 작업에서 수정하지 않았습니다. 보관 정책은 기존 실습 계정에 ARN 범위가 고정되어 있어, 계정 ID만 바꾸면 다른 계정에서도 같은 권한이 생기는 것은 아닙니다. 기존 `SendSSHPublicKey` 허용도 예전 단일 EC2에 한정되어 새 서버에는 적용되지 않습니다. 이 코드는 기존 키를 사용하는 로컬 OpenSSH 접속을 전제로 하며 브라우저 SSH 성공을 보장하지 않습니다.

### 실제 동작 검증

- `ec2-user`로 SSH 접속. 로컬 개인키는 해당 PC에만 둡니다.
- `sudo cloud-init status --wait` 및 필요하면 `/var/log/cloud-init-output.log` 확인. 배포 실패를 SG 문제로 단정하지 않습니다.
- `systemctl is-active nginx`, `systemctl is-enabled nginx` 확인.
- `curl -I http://localhost`에서 HTTP 200 확인.
- 브라우저 `http://<새 IP>/`에서 기본 Nginx 페이지 확인. 과제 A 방식 증빙을 새 IP 기준으로 남깁니다.
- EC2에서 외부 HTTPS 요청 성공 확인.

User Data는 Nginx 기본 페이지를 준비할 뿐 B1-1 사이트를 배포하거나 `/health`를 구현하지 않습니다. 첫 부팅 스크립트이므로 재부팅마다 모두 다시 실행되는 것으로 가정하지 않습니다. 현재 코드에서는 User Data 변경 시 서버 교체가 제안될 수 있습니다. 최신 AMI 조회 결과가 바뀌어도 EC2 교체가 제안될 수 있으므로 plan을 검토합니다.

## 정리도 별도 승인 후

이 구성의 삭제 계획을 보려면 `terraform plan -destroy -out=cleanup.tfplan`을 사용하고, 검토·승인 후 `terraform apply cleanup.tfplan`으로 반영할 수 있습니다. 아직 실행하지 않았습니다.

삭제 후 EC2 종료·EBS 삭제·자원 잔존 여부를 콘솔/조회로 확인하고 과제의 정리 체크리스트와 증빙을 남겨야 합니다. 이 코드가 관리하지 않는 기존 수동 자원이나 기존 키 페어는 삭제되지 않습니다. EIP는 만들지 않지만 계정에 다른 EIP가 남아 있는지는 별도 확인 대상입니다. Terraform destroy만으로 계정 전체 비용이 사라진다고 보장하지 않습니다.
