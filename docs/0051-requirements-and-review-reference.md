# 과제 요구사항과 평가 질문 참조

이 문서는 로컬 원문 `instruction.md`와 `peer-review.md`를 읽고 정리한 저장소용 요약이다. 공식 원문이나 평가자의 판정을 대체하지 않는다. 원문 파일과 쉬운 설명본은 기존 Git 제외 규칙에 따라 로컬에 보존하며 강제로 추가하지 않는다.

[공식 학습 로드맵](https://usr.codyssey.kr/learning/learningMap?projectNo=136003) · [필수/확장 구분](0002-required-checklist-and-extension-rules.md) · [상태 점검](0041-instruction-strict-audit.md)

## 필수 구현

- 서울 리전에서 전용 VPC·Public Subnet·IGW를 구성하고, 적용되는 라우팅 테이블의 기본 경로를 IGW로 연결한다.
- EC2 한 대에 SSH로 접속해 웹 서버를 실행하고, localhost HTTP 정상 응답과 인터넷 아웃바운드를 확인한다.
- HTTP 80은 공개하되 SSH 22는 개인 IP 또는 지정 대역으로 제한한다. 인터넷 전체에 전체 포트를 개방하지 않는다.
- 별도 실습 IAM 사용자/Role을 사용하고 필요한 EC2/VPC/보안 그룹 범위로 제한한다. 과제 사용자에게 AdministratorAccess를 부여하지 않는다.
- 외부 검증은 브라우저의 퍼블릭 IP HTTP 접속(A) 또는 `/health` GET 응답(B) 중 하나를 선택해 README에 방법·주소·결과를 남긴다.

## 필수 제출물 네 가지

1. `docs/architecture.png` 또는 PDF: 필수 구성 요소와 외부 트래픽 흐름.
2. README의 외부 접속 방식·검증 당시 주소와 정상 응답 캡처.
3. `docs/troubleshooting.md` 또는 PDF: 최소 한 건의 증상·가설·검증·조치·결과·재발 방지.
4. `docs/cleanup-checklist.md`: 실제 정리 결과와 근거. 최소 EC2·EBS·EIP·IGW·VPC를 확인하며 생성한 NAT Gateway·ELB/ALB·RDS가 있다면 함께 정리한다. 미할당 자원은 해당 없음 근거를 남긴다.

Billing 확인은 원문에서 권장한다. 예상 비용 0 표시만으로 자원 정리 결과나 무료 범위 준수를 대신하지 않는다.

## 제약과 선택 항목

- 프리 티어 범위 내 진행, 서울 리전, root 대신 별도 IAM 사용자/Role 접근, 필요한 포트만 허용, 종료 후 자원 정리가 요구된다.
- HTTPS와 Docker는 선택 보너스다. Docker를 선택하지 않았다고 필수 미달로 분류하지 않는다.
- Terraform·로컬 AMI 백업·다중 AZ·ALB 구축은 이 과제의 필수 구현이 아니다.
- 과거 root 복구 이력, 현재 예상 비용과 무료 적용의 미확인 사항은 [엄격 점검의 후속 상태](0041-instruction-strict-audit.md)에 사실대로 구분한다.

## 평가에서 설명할 내용

원문 평가 질문은 네 묶음으로 구성된다. 문서가 있다는 사실만으로 학습자의 설명 능력이나 PASS를 확인한 것은 아니다.

1. 구축·SSH·웹 응답·보안 그룹·선택한 외부 검증·최소 다섯 종류 정리 근거.
2. 다이어그램의 트래픽 흐름, 포트 최소화 기준, 검증 방식 선택, 이름·태그·체크리스트 기반 자원 추적.
3. IGW 기본 경로가 필요한 이유, SG와 IAM의 차이, SSH/DB 인터넷 전체 개방 위험, 가설 뒤 검증하는 이유.
4. 접속 장애 점검 순서, API 오류를 근거로 최소 권한을 찾는 방법, 인스턴스 두 대로 확장할 때의 변화, 예상 밖 비용 추적·정리 방법.

연습 답변은 [Aside 초안](0032-peer-review-aside.md)과 [Bridge 초안](0033-peer-review-bridge.md)에 있다. 실시간 시연이 별도로 필요한지와 최종 평가 판정은 확인되지 않았다. 원문은 실습 후 정리를 요구하므로 삭제한 서버를 평가를 위해 무조건 재생성하지 않는다.
