# 과제 너머의 클라우드 기초 — 사수 관점의 확장 지도

[교육 목표와 적정 깊이](0004-educational-goals-and-learning-scope.md) · [수준별 확장 안내](0005-level-appropriate-expansion-guide.md)

> 넓은 지도를 위한 브레인스토밍이다. 전부 이번 과제의 필수 학습은 아니다. 아래 실험은 제안이며 실행한 결과가 아니다. 유료 리소스를 만들거나 보안을 약화시키는 실험은 승인 없이 하지 않는다.

## 1. IP·포트 → 통신의 여러 층

- 지금: IP는 네트워크상의 주소, 포트는 통신 끝점 구분이라는 기본 모델.
- 다음: 사설/공인 IP, IPv4/IPv6, TCP 연결, DNS 이름 해석, HTTP 상태.
- 이후: 패킷 캡처·MTU·연결 추적·TCP 재전송.

사수 질문: ‘DNS 조회 실패, TCP 연결 실패, HTTP 404는 같은 장애인가?’

관찰: 브라우저·curl 출력에서 어느 단계까지 진행했는지 구분한다. ping 실패만으로 HTTP 불가를 단정하지 않는다.

검색어: `IP address`, `TCP port`, `DNS resolution`, `connection refused vs timeout`.

## 2. VPC·Subnet → 주소 계획과 격리

- 지금: CIDR 표기, 주소 범위를 나누는 이유, Subnet의 위치.
- 다음: 리전/AZ, Public/Private Subnet, 겹치지 않는 주소 계획, IPv6.
- 이후: VPC Peering·Transit Gateway·VPN·하이브리드 네트워크.

사수 질문: ‘이름을 public으로 바꾸면 인터넷에서 접속 가능한가?’

관찰: 이름 대신 라우팅·퍼블릭 주소·접근 규칙을 확인한다. 이번에는 서브넷 계산 능력 전체를 선행 조건으로 삼지 않는다.

검색어: `CIDR`, `Availability Zone`, `public private subnet`, `address overlap`.

## 3. Route Table·IGW → 요청과 응답의 경로

- 지금: 목적지별 경로, 기본 경로, Subnet 연결 관계.
- 다음: 가장 구체적인 경로 선택, 반환 경로, NAT Gateway와 IGW 차이.
- 이후: 네트워크 분리·VPC Endpoint·중앙 egress 설계.

사수 질문: ‘IGW가 있는데 왜 EC2가 인터넷에 못 나갈까?’

관찰: IGW 존재와 Subnet이 실제 사용하는 Route Table을 구분한다. 이번 공개 IPv4 EC2 실습에 NAT Gateway를 습관적으로 추가하지 않는다.

검색어: `default route`, `route association`, `longest prefix match`, `NAT vs Internet Gateway`.

## 4. Security Group → 여러 보안 경계

- 지금: 프로토콜·포트·소스, inbound/outbound, 최소 공개 범위.
- 다음: stateful SG와 stateless NACL, OS 방화벽, 허용 규칙의 합성.
- 이후: WAF·DDoS 대응·세분화된 네트워크 정책.

사수 질문: ‘SG에 허용했으면 서버 프로세스도 반드시 실행 중인가?’

관찰: 클라우드 경계·OS 경계·서비스 리스닝을 나눠 확인한다. 접근 장애를 전체 포트 공개로 해결하지 않는다.

검색어: `stateful firewall`, `security group vs NACL`, `least exposure`, `listening socket`.

## 5. IAM → 신원·관리 권한·임시 자격

- 지금: 사용자/Role/Policy, 인증과 권한, 필요한 작업만 허용.
- 다음: Action/Resource/Condition, AssumeRole·STS·임시 자격, MFA, EC2 Instance Profile.
- 이후: IAM Identity Center·조직 정책·권한 경계·크로스계정 접근.

사수 질문: ‘IAM에서 EC2 권한이 있어도 SSH 키가 필요한 이유는?’

관찰: AWS 관리 API 신원과 Linux 로그인 신원을 분리한다. 최소권한은 서비스명만 좁히는 것으로 끝나지 않고 가능한 리소스·조건도 검토한다. 일부 작업은 리소스 단위 제한이 지원되지 않으므로 공식 권한 문서를 확인한다.

검색어: `principal`, `IAM policy`, `STS`, `instance profile`, `authentication authorization`.

## 6. EC2·EBS → 컴퓨터·디스크·수명 주기

- 지금: 인스턴스·AMI·인스턴스 유형·볼륨, Stop과 Terminate.
- 다음: 재부팅·공인 IP 변화, DeleteOnTermination, 스냅샷, 아키텍처 차이.
- 이후: 이미지 표준화·Auto Scaling·예약/절감 상품·재해 복구.

사수 질문: ‘인스턴스를 없앴는데 디스크나 스냅샷은 남지 않았나?’

관찰: 컴퓨트 상태와 데이터 보존을 따로 확인한다. 스냅샷은 백업의 재료지만 복원 검증 없이 복구 가능성을 확정하지 않는다.

검색어: `AMI`, `EBS lifecycle`, `DeleteOnTermination`, `snapshot restore`.

## 7. SSH·Linux → 접속 이후의 운영

- 지금: 공개키/개인키, 사용자, 파일 경로·권한, 패키지·프로세스·서비스.
- 다음: systemd·journalctl, 디스크/메모리 확인, SSH 호스트키와 서버 신원 확인.
- 이후: Session Manager·패치 자동화·불변 서버 운영.

사수 질문: ‘Permission denied가 네트워크 차단과 같은 문제인가?’

관찰: 연결·호스트 확인·사용자 인증을 단계별로 본다. 호스트키 검사를 무조건 끄거나 개인키를 저장소에 올리지 않는다.

검색어: `SSH host key`, `public key authentication`, `Linux permissions`, `systemd`, `journalctl`.

## 8. Nginx → HTTP 서버와 애플리케이션 경계

- 지금: 정적 파일·document root·포트·서비스 상태·access/error 로그.
- 다음: server block·Host 헤더·reverse proxy·HTTP 캐시·TLS 종료.
- 이후: 로드밸런서·애플리케이션 서버·고가용성.

사수 질문: ‘Nginx가 200을 준다고 GitHub API 카드까지 정상이라고 말할 수 있나?’

관찰: HTML 제공과 브라우저의 CSS/JS/API 동작을 구분한다. /health 고정 문구는 그 응답 경로가 동작한다는 증거이지 모든 의존성의 건강 보장이 아니다.

검색어: `document root`, `server block`, `reverse proxy`, `access log`, `health check`.

## 9. HTTPS·Docker → 선택 도구의 목적

- 지금: HTTP와 암호화 통신 차이, 도메인·인증서의 역할은 개념으로 이해.
- 다음: 인증서 갱신, 이미지/컨테이너, 호스트와 컨테이너 포트 매핑.
- 이후: 오케스트레이션·이미지 공급망·자동 인증서 관리.

사수 질문: ‘컨테이너가 Up이면 외부 접속도 반드시 가능한가?’

관찰: 컨테이너 프로세스·포트 매핑·호스트·SG·라우팅을 따로 본다. 선택 기능을 필수 학습의 선행 조건으로 바꾸지 않는다.

검색어: `TLS certificate`, `renewal`, `Docker port publishing`, `image vs container`.

## 10. 장애 보고서 → 증거 기반 문제 해결

- 지금: 증상·가설·검증·조치·결과·재발방지, 변경 전후 비교.
- 다음: 로그 시간대·상관관계, CloudTrail과 서비스 로그의 차이, 변경 이력.
- 이후: metrics/logs/traces·알림·SLO·인시던트 대응.

사수 질문: ‘무엇을 바꿔서 고쳐졌는지 모른다면 같은 문제를 다시 해결할 수 있나?’

관찰: 한 번에 한 가설을 검증한다. CloudTrail 관리 이벤트 기록이 모든 웹 요청 로그를 대신하지는 않는다. VPC Flow Logs 등 추가 관찰 도구도 설정·비용을 먼저 검토한다.

검색어: `hypothesis-driven debugging`, `CloudTrail`, `observability`, `postmortem`.

## 11. 비용·정리 → 실습도 운영이다

- 지금: 생성 목록·리전·리소스 ID·정리 책임, 시간·용량·주소 등 비용 요인.
- 다음: 태그·예산 알림·비용 표시 지연·미사용 자원 확인.
- 이후: Infrastructure as Code·비용 배분·정책 자동화·FinOps.

사수 질문: ‘컴퓨터를 껐으니 과금도 전부 멈췄다고 말할 수 있나?’

관찰: 예산 알림은 보통 지출을 자동으로 강제 차단하는 장치가 아니다. 현재 계정의 보호 기능과 적용 조건은 별도로 확인한다. Terraform/CDK 같은 자동화도 생성·삭제할 대상을 모르면 안전을 보장하지 않는다.

검색어: `resource inventory`, `AWS Budgets`, `cost allocation tags`, `Infrastructure as Code`.

## 12. 이번에 배울 것과 나중에 배울 것

지금은 단일 서버로 경로·권한·동작·실패·정리를 설명하는 것이 우선이다. 다음 도구를 모두 쓰는 것이 클라우드 기초의 완성이 아니다.

- Kubernetes보다 먼저 EC2 프로세스와 포트.
- Terraform보다 먼저 실제 리소스와 의존성.
- 고가용성보다 먼저 단일 요청의 성공·실패 경로.
- 모니터링 플랫폼보다 먼저 상태·로그·가설.
- 복잡한 권한 조직 설계보다 먼저 IAM과 SG의 차이.

공식 학습 경로: [AWS VPC 문서](https://docs.aws.amazon.com/vpc/), [EC2 문서](https://docs.aws.amazon.com/ec2/), [IAM 문서](https://docs.aws.amazon.com/iam/), [AWS 요금](https://aws.amazon.com/pricing/). 링크는 참고 경로이며 여기서 최신 가격·기능 지원을 조회해 확정한 것은 아니다.
