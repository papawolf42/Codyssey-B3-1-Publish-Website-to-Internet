# 분할 커밋과 검증 기록

[승인된 계획](0050-submission-and-commit-plan.md) · [현재 README](../README.md)

## 범위

- 브랜치: `study`. 시작 HEAD: `0584f24`.
- 주제별 8묶음, 변경 대상 236개 파일. 초기 234개에 사용량 상세 가독성 보완 캡처 2장을 추가했다.
- main 병합·원격 push·이력 재작성은 실행하지 않았다.
- AWS·Cloudflare 자원 변경·재생성·복원은 하지 않았다. 상세 캡처 보완 때 Billing을 읽기 전용으로 재조회했다.

## 순서별 커밋

1. **학습 계획·워크북**: `5d7b7c1`, 18개 파일.
   - `docs: organize cloud learning plans and workbook`
2. **접근 복구·네트워크·EC2 배포·보안**: `e3c94ee`, 103개 파일.
   - `docs: record EC2 deployment and access troubleshooting`
3. **아키텍처·설명 학습 자료**: `49f87c9`, 17개 파일.
   - `docs: add architecture diagrams and review learning notes`
4. **Terraform 학습용 코드·로컬 검증**: `6e97ca2`, 15개 파일.
   - `feat(infra): add locally validated Terraform learning stack`
5. **HTTPS 보너스·검증**: `2275d23`, 20개 파일.
   - `docs: document HTTPS setup and certificate renewal test`
6. **AMI 로컬 백업·복원 참고**: `83e8c59`, 17개 파일.
   - `docs: record local AMI archive verification and restore guide`
7. **자원 정리·현재 비용 확인**: `64c2533`, 43개 파일.
   - `docs: record resource cleanup and provisional billing checks`
8. **제출 현황 최종 정합성**: README·엄격 점검의 후속 상태·이 실행 기록, 3개 파일.
   - `docs: reconcile submission status and remaining limitations`
   - 이 문서를 포함하는 마지막 커밋 자체의 해시는 자기 참조를 피하기 위해 넣지 않는다. `git log --oneline -8`과 작업 완료 보고에서 확인한다.

## 검증 결과

- 각 묶음의 명시적인 파일 목록으로 스테이징하고 목록·통계·기존 파일 diff·새 문서/소스 범위를 확인했다. 각 커밋 전 `git diff --cached --check`를 통과시켰다. 한꺼번에 `git add .`를 쓰거나 이미 만든 커밋을 amend/reset하지 않았다.
- 커밋 후보 텍스트 84개에서 개인키·age 복구키·AWS 액세스 키·서명 URL·JWT·PAT·비밀키 대입 패턴에 해당하는 값을 발견하지 못했다. 비밀 값을 출력하지 않았다.
- 위험도가 높은 로그인/암호 복구·SSH·프로필·AMI 캡처 29장을 독립 시각 점검했고 노출된 인증정보를 발견하지 못했다. 추가 Billing 상세 캡처도 저장 후 직접 확인했다. 전체 이미지 메타데이터·가림 복구 가능성·과거 Git 이력에 대한 완전한 감사를 했다는 뜻은 아니다.
- 문서 상대 파일 링크, JSON, Excalidraw 이미지 참조 오류를 발견하지 못했다. 제목 앵커·외부 사이트 가용성 전체를 자동 검증한 것은 아니다.
- 기존 Terraform 실행 파일로 fmt check·validate를 통과하고 mock 테스트 **6 passed, 0 failed**를 재확인했다. Terraform 일반 AWS plan/apply/destroy 및 실제 부팅은 실행하지 않았다. Linux User Data는 `.gitattributes`로 LF를 유지한다.
- provider 캐시·실제 tfvars·state/plan·SSH 개인키·암호화 백업과 복구키는 커밋하지 않았다. provider lock 파일과 예제 입력값은 코드와 함께 보관했다.

## 제외 규칙과 이식성

- 원문 `instruction.md`, 쉬운 설명 원문, `peer-review.md`는 기존 제외 규칙을 존중해 force-add하지 않았다. 깨지는 저장소 내 링크는 [요구·평가 요약](0051-requirements-and-review-reference.md)으로 연결했다. 다른 로컬 B1-1 저장소를 가리키던 링크도 로컬 참고임을 표시했다.
- 루트 `.gitignore` 자체도 기존 `.git/info/exclude`의 로컬 제외 대상이다. 그 규칙을 강제로 해제하지 않았으며 이 로컬 파일에 AMI 아카이브·암호화 백업·복구키 보호 패턴을 추가했다. 이 파일은 원격 클론으로 전달된다고 주장하지 않는다.
- `infra/terraform/.gitignore`와 `.gitattributes`는 실제 커밋에 포함돼 Terraform 코드와 함께 이식된다.

## 문서 정합성 보완

- Nginx 기본 페이지 검증과 미수행 B1-1 콘텐츠 배포를 구분했다.
- 삭제 전 웹·SSH·SG 증빙과 정리 후 상태, DNS·IAM·키 페어 보존을 구분했다.
- 브라우저 SSH의 IAM 저장과 실제 성공 미검증, 로컬 OpenSSH 성공을 구분했다.
- 보관 정책 v3 사본·제안본·후속 UI 기본 v7 관찰을 구분하고 v7 전체 JSON 미대조를 명시했다.
- 초기 Billing 상세 캡처 0262가 요약 영역만 보여 실제 요청 수·단가 행이 보이는 0269·0270을 추가했다. 초기 증빙을 다른 시각의 이미지로 덮어쓰지 않았다.

## 남아 있는 과제 상태

주요 실습 자원 정리는 확인됐다. 무료 범위·EC2 사용료 미표시 원인·확정 청구, 계정 전체 추가 자원의 미조회 범위, DNS 유지에 따른 향후 IP 변경, 로컬 ttyd 종료, 학습자 자기 설명 및 실제 평가 PASS는 별도 후속 사항이다. 과거 root 복구 이력도 지우지 않았다.

`study` 학습 기록의 커밋 완료와 `main` 제출본 선별·병합·push는 별개다. 후자는 별도 승인 전에 진행하지 않는다.
