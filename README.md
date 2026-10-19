# B3-1 AWS EC2 웹 서버 배포

서울 리전에서 VPC·Public Subnet·Internet Gateway·EC2·Security Group을 구성하고, Nginx 웹 페이지의 외부 접속을 검증한 개인 실습입니다.

> 아래 IP·도메인과 화면은 실습 검증 당시의 기록입니다. 네트워크 구성과 서버 응답은 실제 AWS에서 확인했습니다.

## 구성

- 리전: 서울 `ap-northeast-2`
- VPC: `10.0.0.0/16`
- Public Subnet: `10.0.1.0/24`, `ap-northeast-2a`
- 기본 경로: `0.0.0.0/0 → Internet Gateway`
- 서버: Amazon Linux 2023, `t3.micro`, gp3 EBS 8 GiB, Nginx
- 인바운드: HTTP 80 공개, SSH 22 개인 IP `/32` 제한. HTTPS 보너스에서 443 추가
- 실습 사용자: `forB3-1`, EC2/VPC 구성 중심의 고객 관리형 IAM 정책 사용

## 아키텍처

![필수 HTTP 실습 아키텍처](docs/architecture.png)

[편집 원본](docs/architecture.excalidraw) · [요구사항별 검증과 구성 설명](docs/verification.md)

그림은 필수 HTTP·SSH 검증 단계의 구성입니다. HTTPS 443 추가는 보너스 검증에서 구분합니다.

## 외부 접속 검증: A 선택

- 방법: 외부 브라우저에서 `http://13.125.99.141/` 접속
- 결과: **Welcome to nginx!** 정상 표시
- localhost: EC2에서 `curl -i http://localhost`로 **HTTP 200 및 HTML 본문** 확인
- 아웃바운드: EC2에서 `curl -I --max-time 15 https://example.com`으로 **HTTP/2 200** 확인

![외부 브라우저 정상 응답](docs/captures/0193-nginx-external-http-success.png)

검증 당시 인스턴스는 `i-05d34639a30bbfb6a`입니다. `/health` 방식 B를 함께 구현했다고 주장하지 않습니다.

## 필수 제출물

1. [아키텍처 PNG](docs/architecture.png)와 [구성·검증 설명](docs/verification.md)
2. 이 README의 외부 접속 방식 A와 결과 화면
3. [트러블슈팅 보고서](docs/troubleshooting.md): IAM 비밀번호 분실·로그인 경로 혼동 → 기존 관리 접근 복구 → 암호 재설정 → MFA 재로그인 성공
4. [리소스 정리 체크리스트](docs/cleanup-checklist.md): EC2·EBS·EIP·IGW·VPC와 연결 자원의 실제 결과

## 검증 후 원본 리소스 정리

2026-10-19에 원본 EC2의 Terminated 상태와 EBS·EIP 없음, 실습 SG·Subnet·IGW·VPC 및 기본 라우팅 테이블 부재를 확인했습니다. 기본 VPC는 보존했습니다. 정리 기록의 대상은 위 원본 인스턴스이며 이후 평가용 복원과 구분합니다.

[정리 결과와 항목별 캡처](docs/cleanup-checklist.md)

## 선택 보너스: HTTPS

보유 도메인 `kodyssey.kr`에 Let's Encrypt 인증서를 적용하고 브라우저 HTTPS·인증서 검증을 유지한 GET 200·모의 갱신 성공을 확인했습니다.

[HTTPS 적용과 검증 결과](docs/https.md) · [HTTPS GET 200 캡처](docs/captures/0218-https-get-200.png)

## 제출 자료 읽는 순서

**아키텍처 → 구성·검증 → 트러블슈팅 → 자원 정리 → HTTPS** 순으로 확인할 수 있습니다. 각 문서에는 해당 결과를 보여주는 원본 캡처를 연결했습니다. 현재 저장소의 자료는 직접 수행한 실습을 정리한 것이며, 이후 평가용 복원은 기존 자원 ID·검증 시점과 구분합니다.
