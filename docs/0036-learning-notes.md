# 실습하며 다룬 학습 내용 24개

> 아래는 실습 당시 개념과 확인 내용을 모은 자료다. EC2와 실습 네트워크는 후속 정리했으며, 비용·보존 자원·미확인 사항은 [최신 체크리스트](cleanup-checklist.md)를 따른다.

[학습 보드 원본](architecture-learning.excalidraw) · [아키텍처 원본](architecture.excalidraw)

이 문서는 실습 과정에서 확인·설명한 내용을 정리한 것입니다. 복습할 때 각 주제를 직접 설명해 보도록 돕는 참고 자료이며, 미완료 항목은 별도로 표시합니다.

## 01 · 이번 과제의 완료 조건

상태: **실습 확인 / 주요 자원 정리 확인 / 제약·설명 최종 판정 별도**

- 네트워크·서버·보안을 함께 구성하는 과제다.
- SSH, 내부 HTTP, 외부 접속, 아웃바운드를 검증했다.
- 그림·증빙·트러블슈팅·정리 체크리스트가 필요하다.
- 서버가 보인다고 리소스 정리까지 끝난 것은 아니다.

근거: [요구사항 요약](0051-requirements-and-review-reference.md) · [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md)

## 02 · 계정과 로그인 신원

상태: **실습 확인 + 개념 정리**

- AWS 계정, IAM 사용자, 역할은 서로 다르다.
- Builder ID 로그인과 root 로그인도 다른 경로다.
- 계정 ID와 현재 역할/사용자 표시로 작업 대상을 확인한다.
- 같은 이메일이나 별칭만으로 같은 권한이라고 판단하지 않는다.
- 관리 계정의 root라도 멤버 계정 IAM이 합쳐서 보이지는 않는다.
- SSO 계정 목록이 비어도 애플리케이션 할당 경로를 확인한다.

근거: [0024-aws-login-recovery-쉬운설명.md](0024-aws-login-recovery-쉬운설명.md) · [0029-aws-login-ui-from-home-쉬운설명.md](0029-aws-login-ui-from-home-쉬운설명.md)

## 03 · MFA와 콘솔 접근 복구

상태: **실습 확인**

- 기존 관리자 역할에서 IAM 콘솔 암호를 재설정했다.
- MFA는 유지했고 새 암호로 재로그인을 확인했다.
- 암호·MFA 코드·개인키는 채팅과 Git에 남기지 않는다.
- IAM 사용자를 조회하는 것과 그 사용자로 로그인하는 것은 다르다.

근거: [0024-aws-login-recovery-쉬운설명.md](0024-aws-login-recovery-쉬운설명.md) · [0018-iam-console-login-and-mfa.md](0018-iam-console-login-and-mfa.md)

## 04 · IAM 정책을 읽는 네 항목

상태: **실습 확인 + 개념 정리**

- Effect: 허용인지 거부인지.
- Action: 무엇을 할 수 있는지. Resource: 어느 대상인지.
- Condition: 어느 리전·사용자 등 어떤 조건인지.
- 정책 이름이 아니라 실제 연결 정책의 JSON을 읽어야 한다.

근거: [0030-iam-policy-reading-쉬운설명.md](0030-iam-policy-reading-쉬운설명.md) · [policies/b3-1-ec2-seoul-policy.json](policies/b3-1-ec2-seoul-policy.json)

## 05 · 권한 누락과 상위 정책 거부

상태: **실습 확인**

- no identity-based policy allows는 허용 작업 누락을 뜻한다.
- explicit deny in SCP는 조직의 명시적 거부와 구분한다.
- 서울 조회의 SCP 거부와 이후 정상 조회를 기록했다.
- 실패했다고 AdministratorAccess부터 붙이지 않는다.
- 서울 리전 예외만 최소 수정하고 같은 주체로 조회를 재검증했다.

근거: [troubleshooting.md](troubleshooting.md) · [0028-browser-ssh-troubleshooting.md](0028-browser-ssh-troubleshooting.md)

## 06 · VPC와 CIDR

상태: **실습 확인 + 개념 정리**

- VPC는 AWS의 논리적으로 구분된 가상 네트워크다.
- 실습 VPC의 IPv4 범위는 10.0.0.0/16이다.
- CIDR의 /숫자는 주소 범위를 나타내는 접두사 길이다.
- 기본 VPC와 실습 VPC는 이름뿐 아니라 ID로 구분한다.

근거: [0019-vpc-network-walkthrough.md](0019-vpc-network-walkthrough.md) · [0011-vpc-basics.md](0011-vpc-basics.md)

## 07 · Subnet과 가용 영역

상태: **실습 확인 + 개념 정리**

- 서브넷은 VPC 주소 범위의 일부이며 하나의 AZ에 속한다.
- 실습은 10.0.1.0/24, 서울의 ap-northeast-2a를 사용했다.
- /24는 256개 주소이고 AWS 예약 5개를 뺀다.
- 서브넷 주소가 VPC 범위 안에 포함되는지 확인한다.

근거: [0019-vpc-network-walkthrough.md](0019-vpc-network-walkthrough.md) · [0022-subnet-settings-쉬운설명.md](0022-subnet-settings-쉬운설명.md)

## 08 · Public Subnet의 조건

상태: **실습 확인 + 개념 정리**

- 이름에 Public을 붙이는 것만으로 퍼블릭이 되지 않는다.
- 서브넷에 적용된 라우팅에 IGW 경로가 있어야 한다.
- EC2의 인터넷 통신에는 공인 IP·보안 규칙도 따로 필요하다.
- 서브넷의 자동 IP 설정과 EC2의 공인 IP 설정은 구분한다.

근거: [0019-vpc-network-walkthrough.md](0019-vpc-network-walkthrough.md) · [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md)

## 09 · Internet Gateway의 역할

상태: **실습 확인 + 개념 정리**

- Internet Gateway는 VPC와 인터넷 사이의 관문이다.
- 생성한 뒤 올바른 실습 VPC에 연결해야 한다.
- 연결만으로 모든 서브넷이나 포트가 자동 공개되지는 않는다.
- 라우팅·공인 IP·Security Group 조건을 함께 확인한다.

근거: [0019-vpc-network-walkthrough.md](0019-vpc-network-walkthrough.md)

## 10 · Route Table과 기본 경로

상태: **실습 확인 + 개념 정리**

- Route Table은 서브넷에 적용되는 경로 규칙이다.
- 0.0.0.0/0 → IGW와 VPC 내부 local 경로를 함께 둔다.
- 더 구체적인 local /16이 기본 경로 /0보다 우선한다.
- 명시적 연결이 없어도 기본 테이블을 암시적으로 사용할 수 있다.

근거: [0019-vpc-network-walkthrough.md](0019-vpc-network-walkthrough.md) · [0023-route-targets-쉬운설명.md](0023-route-targets-쉬운설명.md)

## 11 · Security Group의 역할

상태: **실습 확인 + 개념 정리**

- Security Group은 EC2 네트워크 통신을 제어한다.
- IAM은 AWS API 작업 권한을 제어하므로 역할이 다르다.
- 허용 규칙에 없는 새 인바운드 접속은 허용되지 않는다.
- 응답 트래픽에는 연결 상태를 추적하는 특성이 적용된다.

근거: [0019-vpc-network-walkthrough.md](0019-vpc-network-walkthrough.md) · [0030-iam-policy-reading-쉬운설명.md](0030-iam-policy-reading-쉬운설명.md)

## 12 · 포트와 출발지 제한

상태: **실습 확인**

- 웹 공개용 HTTP TCP 80은 모든 IPv4에서 허용했다.
- 관리용 SSH TCP 22는 내 공인 IP /32만 허용했다.
- /32는 IP 한 개 제한이지 로그인 사용자 인증이 아니다.
- 같은 default 이름도 VPC가 다르면 다른 보안 그룹이다.

근거: [0019-vpc-network-walkthrough.md](0019-vpc-network-walkthrough.md) · [0028-browser-ssh-troubleshooting.md](0028-browser-ssh-troubleshooting.md)

## 13 · 인바운드와 아웃바운드

상태: **실습 확인 + 개념 정리**

- 인바운드는 서버로 들어오는 연결, 아웃바운드는 나가는 연결이다.
- 80번 인바운드만 열어도 별도 규칙으로 외부 HTTPS를 요청할 수 있다.
- example.com은 아웃바운드 시험 대상이지 시스템 구성 요소가 아니다.
- 실습의 기본 아웃바운드 허용은 가장 엄격한 출구 제한은 아니다.

근거: [0019-vpc-network-walkthrough.md](0019-vpc-network-walkthrough.md) · [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md)

## 14 · EC2, AMI, 인스턴스 유형

상태: **실습 확인 + 선택 이유 정리**

- AMI는 서버 OS 등의 시작 이미지, 유형은 CPU·메모리 규격이다.
- 실습은 Amazon Linux 2023과 t3.micro를 사용했다.
- CPU 크레딧은 표준으로 선택하고 불필요한 옵션을 피했다.
- micro라는 이름만으로 현재 비용이 무조건 무료인 것은 아니다.

근거: [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md) · [요구사항 요약](0051-requirements-and-review-reference.md)

## 15 · 저장소와 공유 파일 시스템

상태: **선택 확인 + 개념 정리**

- 루트 EBS는 OS가 들어 있는 볼륨이며 gp3 8 GiB를 사용했다.
- EFS·FSx 같은 공유 파일 시스템과 루트 볼륨은 용도가 다르다.
- 이번 단일 웹 서버에는 추가 공유 파일 시스템을 선택하지 않았다.
- 그림에서 EBS를 생략했어도 실습 당시 실제 볼륨은 존재했고 정리 대상이었다. 해당 루트 볼륨은 후속 부재 확인했다.

근거: [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md) · [0027-ec2-file-system-options-쉬운설명.md](0027-ec2-file-system-options-쉬운설명.md)

## 16 · SSH 키와 접속 프로그램

상태: **실습 확인 + 개념 정리**

- RSA·ED25519는 알고리즘, PEM·PPK는 파일 형식이다.
- OpenSSH·PuTTY는 SSH 접속 프로그램이다.
- 공개키와 개인키의 역할은 다르고 개인키 원문을 서버에 보내지 않는다.
- 키 파일 확장자만 바꾸는 것은 형식 변환이 아니다.

근거: [0026-ssh-keypair-openssh-putty-쉬운설명.md](0026-ssh-keypair-openssh-putty-쉬운설명.md)

## 17 · 로컬 SSH와 Windows 권한

상태: **접속 성공 / 경고 일부 남음**

- 개인키 파일 권한이 너무 넓으면 OpenSSH가 사용을 거부한다.
- ACL을 조정한 뒤 ec2-user로 로그인하는 데 성공했다.
- 서버 host key는 서버의 신원을 확인하는 정보다.
- known_hosts 갱신 경고가 남아도 로그인 성공 여부와 구분했다.

근거: [troubleshooting.md](troubleshooting.md) · [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md)

## 18 · 브라우저 Instance Connect

상태: **실패 분석 / 성공 미검증**

- 브라우저 연결은 임시 공개키 전송용 API 권한이 따로 필요하다.
- 키 전송은 실습 서버·ec2-user·서울 범위로 제한했다.
- AWS 서비스의 접속 출발지는 내 PC와 다를 수 있다.
- 브라우저 SSH 성공은 확인하지 않았고 최종 경로는 로컬 SSH다.
- 제한해 추가한 IAM 정책 버전 3은 회수 완료로 확인되지 않았다.

근거: [0028-browser-ssh-troubleshooting.md](0028-browser-ssh-troubleshooting.md) · [0030-iam-policy-reading-쉬운설명.md](0030-iam-policy-reading-쉬운설명.md)

## 19 · Nginx 실행과 자동 시작

상태: **실습 확인**

- 설치되어 있어도 서비스가 실행 중인 것은 아니다.
- systemctl enable --now nginx로 실행과 자동 시작을 등록했다.
- localhost 연결 실패가 서비스 시작 뒤 HTTP 200으로 바뀌었다.
- 자동 시작 설정은 재부팅 후 정상 동작을 무조건 보장하지 않는다.

근거: [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md)

## 20 · HTTP 응답과 검증 범위

상태: **실습 확인 + 개념 정리**

- curl -I는 HEAD 요청으로 응답 헤더를 확인한다.
- 브라우저 GET은 본문을 받으며 외부 페이지 표시를 따로 검증했다.
- 제출 검증은 A 방식이며 /health를 구현한 것은 아니다.
- 내부 HTTP 200과 외부 접속 성공은 서로 다른 시험이다.

근거: [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md) · [../README.md](../README.md)

## 21 · 가설을 검증하는 트러블슈팅

상태: **실습 확인**

- 증상 → 가설 → 검증 → 최소 조치 → 결과 → 재발방지로 기록한다.
- 조회 권한 오류를 자원이 없다는 증거로 오해하지 않는다.
- localhost 실패에는 서버 프로세스를 먼저 확인했다.
- 실패 문구·정책 JSON·전후 캡처를 실제 근거로 사용했다.

근거: [troubleshooting.md](troubleshooting.md) · [0028-browser-ssh-troubleshooting.md](0028-browser-ssh-troubleshooting.md)

## 22 · 과금과 리소스 정리

상태: **주요 자원 정리 확인 / 예상 비용 0.00 조회 / 확정 청구 미확인**

- EC2 실행, EBS, 퍼블릭 IPv4 등에 비용이 생길 수 있다.
- EIP와 자동 할당 퍼블릭 IP는 같은 자원이 아니다.
- 중지만으로 모든 비용이 사라지는 것은 아니다.
- EC2·EBS·EIP 여부·IGW·VPC를 확인하고 정리 증빙을 남겨야 한다.
- Free/Paid 요금제와 New/Advanced 관리 기능은 별개다.
- 고급 기능 전환은 되돌릴 수 없고 spend limit이 제거된다.
- 유료 전환·관리 권한 변경은 사용자 확인 후 진행한다.

근거: [0012-aws-credits-and-cost-check.md](0012-aws-credits-and-cost-check.md) · [요구사항 요약](0051-requirements-and-review-reference.md) · [0025-ec2-deployment-walkthrough.md](0025-ec2-deployment-walkthrough.md) · [0017-aws-plan-upgrade-walkthrough.md](0017-aws-plan-upgrade-walkthrough.md)

## 23 · 로컬 웹 터미널 ttyd

상태: **실습 확인**

- 브라우저는 터미널을 보여주고 실제 SSH는 내 PC에서 실행한다.
- 127.0.0.1 전용·다른 Origin 차단·접속 한 개로 제한했다.
- 중복 탭이 연결 자리를 차지해 안 뜬 문제를 해결했다.
- 탭 닫기와 ttyd 서버 종료, EC2 종료는 서로 다르다.

근거: [0031-local-ttyd-쉬운설명.md](0031-local-ttyd-쉬운설명.md)

## 24 · MCP·에이전트·도식화

상태: **연결·그림 작성 확인**

- 서버 등록과 실제 도구 호출 성공을 구분했다.
- 공식 로컬 MCP로 그림을 만들고 기존 Excalidraw 탭에 반영했다.
- 수정 원본과 제출 PNG는 따로 보관하고 함께 갱신한다.
- 복습할 때는 각 주제를 직접 설명하고 확인된 결과와 비교한다.
- 에이전트·세션·모델을 구분하고 요청과 실제 응답을 확인한다.

근거: [0034-excalidraw-mcp-설치와-연결시험.md](0034-excalidraw-mcp-설치와-연결시험.md) · [0035-architecture-diagram-설명.md](0035-architecture-diagram-설명.md) · [0020-herdr-aside-interaction-guide.md](0020-herdr-aside-interaction-guide.md)

## 그림의 아이콘과 색상

VPC·Public Subnet·Internet Gateway·EC2에는 AWS 공식 2026년 7월 아이콘 팩의 SVG를 넣었습니다. 출처: https://aws.amazon.com/architecture/icons/ . 아이콘의 원래 색은 변경하지 않았습니다. 그림의 파랑·초록·노랑 배경과 통신선 색은 공식 AWS 규칙이나 보안 수준이 아니라 작성자가 구분을 위해 선택한 것입니다.

메인 제출 PNG와 학습 보드 전체 그림을 분리해, 학습 노트 때문에 제출 그림이 작아지지 않도록 합니다. 주요 실습 리소스는 정리 확인했고 [체크리스트](cleanup-checklist.md)에 기록했습니다. 로컬 ttyd 서버 종료는 아직 확인하지 않았습니다.
