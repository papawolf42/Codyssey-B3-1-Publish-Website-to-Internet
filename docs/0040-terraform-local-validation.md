# Terraform 작성본 로컬 검증 기록

> **분할 커밋 전 재검증:** 동일 세션의 기존 `tmp/terraform-check/terraform.exe`를 찾아 `fmt -check -recursive`, `validate -no-color`, `test -no-color`를 다시 실행했다. 모두 종료 코드 0이고 **6 passed, 0 failed**였다. PATH 설치·새 다운로드·AWS 일반 plan/apply/destroy는 하지 않았다.

- 검증일: 2026-10-19, 한국 시간.
- 대상: [infra/terraform](../infra/terraform/README.md).
- 범위: 코드 정렬, provider 준비, 문법·스키마 검증, mock 테스트, Git 제외 규칙.
- **일반 AWS plan / apply / destroy / import는 실행하지 않았다. 기존 AWS 자원과 IAM 정책을 변경하지 않았다.**

## 도구 준비

PATH에서 Terraform·OpenTofu 실행 파일을 찾지 못해, 공식 릴리스 목록에서 Terraform Windows amd64 실행 파일을 임시 검증 디렉터리에 받았다. 시스템 PATH에 설치하지 않았다.

- Terraform: `1.16.6`, `windows_amd64`.
- 출처: `https://releases.hashicorp.com/terraform/1.16.6/terraform_1.16.6_windows_amd64.zip`.
- 공식 HTTPS 사이트의 SHA256SUMS와 ZIP의 SHA-256 일치 확인.
- ZIP SHA-256: `6ea2c186e0e76a113af30fbcdcf7a4b4c70756317994a04929e5c90b9e94b1df`.
- 별도의 GPG 서명 검증까지 수행했다고 주장하지 않는다.
- AWS provider: `hashicorp/aws 6.69.1`. init 출력의 `signed by HashiCorp` 확인.
- `.terraform.lock.hcl` 생성. provider 캐시는 `.terraform/` 아래에 있고 Git에서 제외한다.

## 실행 및 결과

검증용 임시 Terraform 실행 파일을 사용해 저장소 루트에서 다음 옵션으로 실행했다.

1. `-chdir=infra/terraform fmt -recursive`: 파일 정렬 완료.
2. `-chdir=infra/terraform fmt -check -recursive`: 종료 코드 0.
3. `-chdir=infra/terraform init -backend=false -input=false -no-color`: 성공. 외부 provider 다운로드는 발생했지만 AWS 계정 자원 조회나 생성은 하지 않았다.
4. `-chdir=infra/terraform validate -no-color`: `Success! The configuration is valid.`
5. `-chdir=infra/terraform test -no-color`: **6 passed, 0 failed.**

### 모의 테스트 6개

- `expected_architecture_and_security`: VPC·서브넷·AZ, 인스턴스별 공인 IP, HTTP 80 공개, SSH 22 제한, t3.micro·표준 CPU 크레딧·암호화 gp3 8 GiB·종료 시 루트 볼륨 삭제, IMDSv2·키 이름·User Data 설정과 Nginx 명령 포함 확인.
- `reject_world_open_ssh`: SSH `0.0.0.0/0` 거부.
- `reject_broader_ssh_range`: SSH `/24` 거부.
- `reject_invalid_ipv4`: 잘못된 IPv4 거부.
- `reject_placeholder_key`: 예제 키 이름 자리표시자 거부.
- `reject_invalid_account_id`: 숫자 12자리가 아닌 계정 ID 거부.

모든 run은 `mock_provider "aws"` 및 `command = plan`이다. AMI 조회도 mock 처리한다. 로컬 입력 검증용 테스트이며 실제 AWS 계정에 대한 일반 plan이나 실제 자원 apply가 아니다.

## 추가 점검

- 선언한 관리 resource는 10개다. IAM·키 페어·개인키·EIP를 생성하는 resource는 없다.
- 실제 `.tfvars` 파일과 Terraform state 파일이 만들어지지 않았음을 폴더 목록으로 확인했다.
- `user-data.sh`에 CRLF가 없음을 확인했다. 실제 Linux 실행이나 shellcheck까지 수행한 것은 아니다.
- 실제 경로 인수의 `git check-ignore`로 `.terraform/`, state, 실제 tfvars, 계획 파일, PEM이 제외되는 것을 확인했다.
- `.terraform.lock.hcl`, `terraform.tfvars.example`, 이식 가능한 `infra/terraform/.gitignore`는 제외되지 않는 것을 확인했다.
- 독립 파일 검토에서 명백한 HCL/provider 설정 오류는 발견되지 않았다. 현재 보관 IAM 정책의 DNS 속성·SG egress 등 중요 권한 누락과 실제 부팅/비용 위험은 사용법에 반영했다.

## 미완료·미검증

- 실제 CLI AWS 인증 경로 및 provider가 사용하는 모든 API의 IAM 허용 여부.
- AWS의 실제 AMI 조회, 새 스택 생성, User Data 실행, SSH·내부/외부 HTTP·아웃바운드 성공.
- 실제 리소스 종료·삭제 및 비용 잔존 확인.
- 기존 수동 자원 import. 현재 코드에 자동 이관 기능은 없다.
- OpenTofu에서의 실행은 검증하지 않았다.

이 로컬 검증 통과는 과제 배포 완료나 비용 무료 보증이 아니다. 실제 실행은 기존 자원 처리 방침과 권한을 검토하고 사용자 확인 후 진행해야 한다.
