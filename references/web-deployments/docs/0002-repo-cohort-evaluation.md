# 0002. 레포 코호트 평가: 10개 계정, 22개 레포

> 시리즈: B6-1(과거 B3-1) "내가 만든 웹사이트를 인터넷에 올려 누구나 쓰게 하기" 과제 분석 문서.
> 2026-10-19 기준, 22개 레포를 full 히스토리(shallow 해제)까지 받아서 커밋 수·산출물 충족·문서 깊이로 평가했다.
> 원본 데이터: `manifest.json` (44개 계정 스캔, 공개 레포 1,382개 중 22개 매칭).

## 1. 과제 번호 혼돈 정리

과목 번호가 재배정되면서 같은 레포명이 서로 다른 과제를 가리킨다. "B3-1" 폴더명만으로는 과제를 구분할 수 없다.

| 레포 수 | 과제 | 계정 |
|---:|---|---|
| 13 | 웹 배포 (현재 **B6-1**, 과거 **B3-1**) | bangahee, bllancck, CMS-SUDO7, giyeop-cody, jha21vvv, kimch0612, kjs83036, mackerel07, segretoo, shannonlee-dev, star-candy, VectorSophie, yun-lim |
| 5 | Mini Redis (현재 **B3-1**) | bangahee/B3-1, CMS-SUDO7/CODY-B3-1, giyeop-cody/B3-1, kjs83036/AI-SW-Basic-B3-1, star-candy/B3-1_mini_redis_codyssey |
| 4 | SQL DB 설계 (현재 **B6-1**) | bllancck/B6-1.sql-db-design, ji-min0/b6-1, segretoo/codyssey-b6-1, VectorSophie/codyssey-b6-1 |

본 평가는 **웹 배포 13개**에 집중한다.

## 2. 티어별 순위

### 1위 tier — 두각

| 레포 | 커밋 | 기간 | 한 줄 평가 |
|---|---:|---|---|
| bangahee/B6-1 | 13 | 6일 (09-02~09-07) | README가 교과서급. 개념 계산까지 풀이 |
| giyeop-cody/B6-1 | 42 | 2개월 (08-09~10-10) | 가장 "엔지니어링"한 접근. IaC + ADR + 이슈 트래커 |
| bllancck/B3-1.aws-infra-base | 61 | 2.5개월 (07-06~09-23) | 자동화 최강. 스크립트 6종 + 검증 로그 + SG 단위테스트 |

### 2위 tier — 탄탄

| 레포 | 커밋 | 기간 | 한 줄 평가 |
|---|---:|---|---|
| shannonlee-dev/secure-cloud-service-infra | 8 | 4개월 (06-05~10-03) | HTTPS 보너스 + CI/운영 툴링 최상. 산출물 얇음 |
| segretoo/codyssey-b3-1 | 13 | 9일 (10-05~10-13) | OCI로 수행, 운영진 승인 근거 첨부. 실전 트러블슈팅 |
| yun-lim/b6-1 | 3 | 4일 (08-24~08-27) | 3커밋에 구조 훌륭. 번호 스크립트 + 증빙 txt+png 쌍 |
| CMS-SUDO7/CODY-B6-1 | 5 | 4일 (09-15~09-18) | 증거 28장, 리소스 실 ID 전체 표기. 재현성 약함 |

### 3위 tier — 양호

| 레포 | 커밋 | 기간 | 한 줄 평가 |
|---|---:|---|---|
| jha21vvv/codyssey_b3-01 | 15 | 2일 (09-15~09-16) | 양의 승리. README 48KB, 스크린샷 30장 |
| kimch0612/Codyssey_B3-1 | 10 | 9일 (08-16~08-24) | A+B 둘 다 검증(유일). README는 짧음 |
| kjs83036/AI-SW-Basic-B6-1 | 14 | 3일 (09-14~09-16) | 보너스 2종(DuckDNS+HTTPS, Docker) 달성. 히스토리 망가짐 |
| star-candy/B6-1_aws_codyssey | 7 | 3일 (05-21~05-23) | 학습 우선. Obsidian 노트 전체 커밋 |

### 4위 tier — 아쉬움

| 레포 | 커밋 | 기간 | 한 줄 평가 |
|---|---:|---|---|
| VectorSophie/codyssey-b3-1 | 3 | 3.5개월 (06-02~09-23) | CLI 자동화는 좋으나 스크린샷 0장 |
| mackerel07/B6-1 | 4 | 2일 (07-07~07-08) | .DS_Store 커밋, 콜론 한글 파일명, 아키텍처 파일 부재 |

## 3. 사람별 상세 코멘트

### bangahee — 개념 체화의 완성

README 28KB/489행.

- CIDR를 비트 단위로 처음부터 계산해 설명한다 — 2^8=256 조합을 비트 수 표로 유도하고, AWS 예약 주소 5개(네트워크 주소/VPC 라우터/DNS/예약/브로드캐스트)를 공제해 "실제 사용 251개"를 유도한다. 개념이 체화됐다는 증거.

- 트러블슈팅이 진짜: 외부 404가 timeout이 아니었으니 요청은 네트워크를 통과했다는 역추론 → Nginx 미reload가 원인 → `nginx -t` 후 reload로 해결.
- 증빙 설계: `0.0.0.0/0` 공개하는 포트는 80 하나, SSH는 개인 IP `/32`, 개인 IP는 스크린샷에서 가림.
- 비밀정보 위생: 로컬 runbook(개인 IAM 이름·로컬 경로·키 위치)은 gitignore로 분리.
- 확장 설계: ALB + 2AZ + Target Group + ASG로 가는 8단계 로드맵.
- Billing USD 0.00 증빙까지. 6일에 이 정도면 집중력도 훌륭.

### giyeop-cody — 가장 엔지니어링한 접근

- CloudFormation(IaC)으로 인프라를 다시 만들 수 있음. Docker Nginx + container healthcheck.
- 의사결정 기록: ADR 2건(`docs/decisions/`), 이슈 트래커 5건(`docs/issues/ISSUE-001~005`), 멘토링 세션 기록, LEARNING.md/QUEST.md.
- 증거 재검증: manifest.json + 고정 커밋 해시(`6bc1076...`)를 남기고, `evidence/2026-10-03/`에 SSH 원본 출력까지.
- 보안 디테일: scan-secrets.sh로 비밀 패턴 스캔, IMDSv2 필수, EBS 암호화, 장기 Access Key 회피(CloudShell 인증), MFA 확인.
- 상태 추적 정직: "확정 청구액은 확인하지 않았다", "예상 청구액" 같은 한계를 명시.
- 단: 문서가 40개 파일로 과도하게 퍼져 있음(과제 하나에 ADR·이슈 트래커까지).

### bllancck — 자동화와 재현성 최강

- 스크립트 6종: `provision.sh / verify.sh / cleanup.sh / test-sg-rules.sh / common.sh / user-data.sh`.
- `verify.sh`로 11개 항목 자동 검증, 결과를 `docs/verification.log`에 기록.
- 보안 그룹 판정 함수에 단위 테스트(`test-sg-rules.sh`)까지 — 13개 중 유일.
- IAM에 `t2.micro/t3.micro`만 `RunInstances` 가능한 과금 가드레일 포함 — 다른 사람은 거의 안 한 디테일.
- 61커밋. docs: 커밋이 압도적(README를 2개월간 갈고닦은 과정이 그대로 기록).
- `docs/ipv4-cidr.md`로 CIDR 개념을 별도 문서화.

### shannonlee-dev — 운영 툴링 최상, 산출물은 얇음

- HTTPS(certbot + DNS) 보너스 달성.
- GitHub Actions CI(`make check`로 문서 링크·문법 검증), Makefile, CODEOWNERS, dependabot, issue template 4종 — 레포 운영이 가장 프로페셔널.
- 단: 커밋 8개에 6월→10월 공백이 큼. README 3KB로 짧고, 산출물이 툴링에 비해 얇아 보임.

### segretoo — OCI로 수행한 유일한 케이스

- AWS 프리티어가 신규 가입자 한정이라 OCI Always Free(도쿄 홈 리전)로 수행.
- 운영진 승인 근거 캡처까지 첨부해 클라우드 교체를 정당화(다른 수강생의 채널 문의 + 운영진 15:55 답변). 판단 근거를 남긴 좋은 사례.
- 실전 트러블슈팅: NSG는 열었는데 OS 방화벽(iptables)이 80을 막고 있었던 발견. "NSG를 열어도 OS 방화벽이 막으면 안 된다"는 핵심 교훈.
- Q&A 형식 학습 섹션(10개 질문), 커밋 컨벤션 문서 + PR 템플릿, 비용 분석(SGD 0.03 확인 후 0.00).
- 스크린샷 42장.

### yun-lim — 3커밋에 구조 훌륭

- 번호 붙은 스크립트: `00-create-iam-user.sh → 01-provision.sh → 03-verify.sh → 05-cleanup.sh`.
- `docs/resource-tracker.md`에 리소스 ID를 만드는 즉시 기록.
- 증빙은 png + txt 쌍(문자열로 재검증 가능).
- README에 "평가 때 설명할 내용" 섹션 — 면접 대비까지.
- 단: 히스토리가 3개라 진행 과정이 안 보임.

### CMS-SUDO7 — 증거는 두텁, 재현성은 약함

- 수동 콘솔 작업인데 증거 스크린샷 28장.
- 리소스 실 ID(`vpc-0e80...`, `sg-09e7...`, `i-0969...`)를 표로 전부 기록.
- 검증 표에 "3/3 결과 미수집"을 있는 그대로 적은 정직함.
- 단: 커밋 5개, 스크립트 없음 — 재현성 약함.

### jha21vvv — 양(量)의 승리

- README 48KB, 스크린샷 30장.
- "증빙 목적 / 확인 요소 / 스크린샷" 3단 구조로 요구사항 6종씩 증빙.
- 트러블슈팅 6단계 프레임워크 + 실제 IAM 권한 2건.
- 단: 2일에 15커밋(README1~8까지 일괄 작업), 스크립트·IAM json 없음, 파일명 `c_(1).png` 식으로 지저분.

### kimch0612 — A+B 둘 다 검증한 유일한 사람

- 검증 방식 A(브라우저)와 B(/health)를 모두 수행.
- 정리 스크린샷 10장, EC2 로그(`ec2_instance_logs.txt`) 첨부.
- README 1.6KB로 짧지만 산출물은 모두 충족.

### kjs83036 — 보너스 2종 달성, 히스토리가 망가짐

- 보너스 2종(DuckDNS 무료 도메인 + HTTPS, Docker nginx:alpine) 모두 달성.
- 단: 커밋이 전부 "Add files via upload"(GitHub 웹 UI 업로드)라 히스토리 가독성 없음.
- README에서 "최소 권한 원칙"이라 쓰면서 실제 정책은 `AmazonEC2FullAccess` + `AmazonVPCFullAccess`, `Resource:*` — 주장과 증거가 안 맞는 점.

### star-candy — 학습 우선

- Obsidian 노트를 통째로 커밋(AWS 개별 개념 카드 30개).
- IAM 정책 JSON을 README에 주석 달아 설명.
- 단: `Resource:*` 사용, `.obsidian` 워크스페이스 파일까지 올라감.

### VectorSophie — 스크린샷이 없다

- AWS CLI 자동화(user-data.sh + iam-policy.json)는 좋으나 스크린샷 0장.
- "외부 접속 증빙"이라는 과제에서 가장 핵심 증거가 빠져서 아쉬움.
- 커밋 3개.

### mackerel07 — 최하위

- 커밋 4개.
- `.DS_Store` 커밋(Mac 메타파일).
- "과제 - AI:SW 기초.pdf"처럼 **콜론**이 들어간 한글 파일명 → Windows 체크아웃 실패 원인.
- 문서가 `docs/` 안쪽에만, 아키텍처 다이어그램 파일 자체가 없음.

## 4. 코호트 공통 패턴

- **공통 골격**: VPC `10.0.0.0/16` → public subnet `10.0.1.0/24` → IGW → `0.0.0.0/0` 라우트 → SG(80 전체 / 22 개인 IP /32) → EC2 Nginx. 전원 같은 구조, 차이는 깊이.
- **검증 방식 B(/health)를 고른 사람이 더 많음.** 이유는 "고정 응답으로 기계 검증 가능 + 향후 LB 헬스체크 재사용" — 이 논리를 쓴 사람이 이해도가 높음.
- **차별화 포인트 순서**:
  1. 자동화 스크립트 / IaC
  2. 증거의 재검증 가능성 (txt + 해시)
  3. 비밀정보 위생 (.pem 미커밋)
  4. 보너스 (Docker / HTTPS / OCI)
  5. 학습 문서 깊이
- **흔한 실수**:
  - 웹 UI 일괄 업로드 → 히스토리 망가짐 (kjs83036)
  - `.DS_Store` 커밋 (mackerel07)
  - 개인 도구(Obsidian) 커밋 (star-candy)
  - README만 방대하고 스크립트 부재 (jha21vvv)

## 5. 산출물 충족 매트릭스

과제 필수 산출물 4종(아키텍처 다이어그램 / 외부 접속 증빙 / 트러블슈팅 보고서 / 리소스 정리 체크리스트) + 부가 항목.

| 레포 | arch | ts | cleanup | 스크린샷 | 스크립트 | IAM json |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| bangahee/B6-1 | O | O | O | 9 | 3 | O |
| bllancck/B3-1.aws-infra-base | O | O | O | 2 | 6 | O |
| CMS-SUDO7/CODY-B6-1 | O | O | O | 28 | - | O |
| giyeop-cody/B6-1 | O | O | O | 67 | 6 | O |
| jha21vvv/codyssey_b3-01 | O | O | O | 30 | - | - |
| kimch0612/Codyssey_B3-1 | O | O | O | 12 | - | - |
| kjs83036/AI-SW-Basic-B6-1 | O | O | O | 6 | - | - |
| mackerel07/B6-1 | - | O | O | 2 | - | - |
| segretoo/codyssey-b3-1 | O | O | O | 42 | - | - |
| shannonlee-dev/secure-cloud-service-infra | O | O | O | 17 | - | - |
| star-candy/B6-1_aws_codyssey | - | O | O | 26 | - | - |
| VectorSophie/codyssey-b3-1 | O | O | O | 0 | 1 | O |
| yun-lim/b6-1 | O | O | O | 7 | 6 | O |

필수 4종이 모두 O인 레포: 11개. 아키텍처 파일이 없는 것: 2개 (mackerel07, star-candy). 스크린샷 0장: 1개 (VectorSophie).

## 6. 한 줄 요약

- 개념 설명은 **bangahee**, 엔지니어링 체계는 **giyeop-cody**, 자동화·재현성은 **bllancck**가 최상위.
- 그 뒤를 **shannonlee-dev / segretoo / yun-lim / CMS-SUDO7**가 잇고,
- **mackerel07**과 **VectorSophie**가 증거·기록 부족으로 하위.
