# 0015. 신규 AWS 프로젝트 환경의 IAM 콘솔 접근 조사

조사일: 2026-10-17. 공식 AWS 문서와 앞서 확인한 실제 화면을 대조했다. 계정/플랜/권한은 변경하지 않았다.

> **후속 통합·정정:** [0016. Q·ChatGPT 리서치 통합](0016-aws-access-research-consolidated.md)을 우선 참고한다. 고급 기능 활성화 후 적립 크레딧이 만료 전까지 자동 적용된다는 공식 FAQ 답변을 직접 확인했다. 앞선 Q/대화의 “유지 근거 미확인”은 정정한다. 다만 FAQ에 만료기간 6개월/12개월이 혼재하므로 실제 계정의 항목별 만료일을 확인해야 한다. 프로젝트 배정 리전·현재 STS 주체·서울 읽기 요청의 실제 결과는 여전히 미확인이다.

## 1. 결론

IAM 사용자 생성 방법을 몰라서 막힌 것이 아니라, 현재 프로젝트형 AWS 가입 방식의 접근 관리·리전 제한과 B3-1 과제 조건이 충돌한다.

- IAM 사용자 `forB3-1`과 EC2 실습 정책의 생성·연결은 이미 완료했다.
- 신규 AWS experience에서는 콘솔 접근이 가능한 IAM 사용자를 생성할 수 없다고 IAM 공식 생성 문서가 명시한다.
- 가입 방식 비교 문서는 신규 환경에서 만든 IAM 사용자·Role은 프로그래밍 접근용이며 콘솔 접근용이 아니라고 설명한다. 사람의 프로젝트 접근은 AWS가 관리하는 방식이다.
- 신규 프로젝트의 리전은 연락처 국가를 기반으로 지정된다. 한국은 시드니 대상이며, 지정 리전을 임의로 바꾸는 기능은 신규 기본 환경에서 지원하지 않는다.
- 따라서 IAM 사용자에 정책을 붙이거나 CLI/Terraform으로 바꾸는 것만으로 별도 최소권한 콘솔 접근과 서울 배치를 충족했다고 주장할 수 없다.

앞서 일반적인 IAM 생성 흐름을 진행하기 전에 이 공식 제한을 확인했어야 했다. 여러 메뉴를 탐색한 것은 해결 방법의 검증이 아니며, 기존 사용자·정책 생성 완료와 과제 접근 조건 충족은 구분해야 한다.

## 2. 공식 근거

### A. IAM 사용자 생성 문서

출처: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html

> In our new experience, you cannot create IAM users with console access.

현재 화면에 콘솔 암호 활성화/설정 항목이 없는 것과 일치한다. 사용자 이름과 권한 정책이 있어도 콘솔 로그인 자격 증명이 생기는 것은 아니다. CLI의 CreateLoginProfile을 임의로 시도해 이 제한을 우회할 수 있다고 가정하지 않는다.

### B. 가입 방식 비교

출처: https://docs.aws.amazon.com/accounts/latest/reference/sign-up-for-aws.html

> If you need fine-grained control over your users or role-based permissions, do not use Sign up for AWS (new).

> You can create IAM roles and IAM users if necessary, but they can only be used for programmatic access, not console access.

신규 환경에서 AWS가 사람의 접근 역할을 관리하고 소유자·팀원에게 프로젝트 관리자 접근을 제공한다고 설명한다. 팀 초대 화면에 모든 개발자 접근 권한을 부여한다고 표시된 것과도 관련된다. 팀 초대를 과제용 EC2/VPC 한정 최소권한의 대체 방법으로 안내하지 않는다.

이 비교 문서는 고급 기능 활성화 전 신규 기본 환경과 advanced 방식을 비교하는 문맥이다. 고급 기능 활성화 후의 Role 접근은 아래 별도 문서의 절차를 참고해야 한다.

### C. 프로젝트 리전 제한

출처: https://docs.aws.amazon.com/accounts/latest/reference/project-regions.html

- 프로젝트 리전은 미국 오하이오, 유럽 스톡홀름, 아시아 태평양 시드니 중 연락처 국가에 따라 지정된다.
- South Korea는 Sydney(ap-southeast-2) 표에 포함된다.
- 연락처 변경으로 기존 지정 리전은 바뀌지 않는다.
- 특정 리전이 필요하면 advanced 가입을 사용하거나 기존 계정에서 고급 기능을 활성화하라고 설명한다.

현재 IAM URL의 region 값만으로 프로젝트의 실제 리전을 확정하는 것은 부족하지만, 앞서 관찰한 시드니 프로젝트와 이 문서의 한국 배정 규칙은 일치한다. 최종 적용 전 프로젝트 추가 정보의 Region도 확인하는 것이 좋다. URL 수정이나 서울 Allow 정책으로 상위 제한이 해제되지는 않는다.

### D. 유료 전환과 고급 기능 활성화는 다름

출처:
- https://docs.aws.amazon.com/accounts/latest/reference/upgrade-account.html
- https://docs.aws.amazon.com/accounts/latest/reference/activate-advanced-features.html

유료 플랜 업그레이드만으로 advanced 전용 기능이 활성화되는 것은 아니다. 공식 설명은 다음과 같다.

- 고급 기능 활성화 전 계정 업그레이드가 필요하다.
- 유료 플랜에서는 크레딧을 넘는 사용 요금을 지불해야 한다.
- 업그레이드는 되돌릴 수 없다.
- 고급 기능 활성화도 되돌릴 수 없다.
- 활성화 시 기존 spend limit이 제거되고 새 spend limit을 만들 수 없다.
- 활성화 후 추가 리전·세부 접근 관리·조직 정책 제어가 제공된다.
- 기존 관리형 역할 보호 정책 등 일부 조직 정책은 활성화 후에도 유지된다. 모든 제한이 자동으로 사라진다고 가정하지 않는다.

따라서 단순히 IAM 사용자 로그인 버튼을 찾기 위해 업그레이드나 고급 기능 활성화를 눌러서는 안 된다. 비용과 계정 구조의 영향을 설명하고 사용자 결정 후에만 진행한다. 아직 아무 전환도 실행하지 않았다.

## 3. 과제를 진행할 수 있는 경로

### 경로 1. 기존 일반(advanced 방식) 계정 또는 교육용 계정 사용

일반 IAM 콘솔 사용자 접근과 서울 리전이 지원되는 계정이 이미 있다면 이번 과제에는 가장 단순한 경로다. 교육용 계정도 기관이 IAM/Role·서울 리전을 허용하는지 확인해야 하며, 모든 교육 계정이 자동으로 적합한 것은 아니다.

일반 IAM 사용자 경로는 다음과 같다.

1. 관리자 주체로 IAM → 사용자 → 사용자 생성을 연다.
2. 실습 사용자 이름을 지정하고 콘솔 접근을 활성화한다.
3. IAM 사용자를 직접 생성하는 경로라면 콘솔 암호와 필요한 암호 변경 옵션을 설정한다.
4. 실습용 정책만 연결하고 사용자 생성 내용을 검토한다. 기존 관리자 정책을 실습 사용자에게 복사하지 않는다.
5. 사용자 생성과 별도로 MFA를 설정한다. 콘솔만 사용한다면 액세스 키는 만들지 않는다.
6. 계정 ID/사용자 이름/암호로 별도 로그인한 뒤 실제 로그인 주체, 서울 리전 및 연결 정책을 확인한다.
7. 그 상태에서 과제 리소스를 생성한다. 초기 관리 설정과 실습 리소스 작업을 구분하고, 루트로 실습을 진행하지 않는다.

AWS의 일반 권장 방식은 사람에게 IAM Identity Center 같은 연동 기반의 단기 자격 증명을 사용하는 것이다. 과제도 IAM Role을 허용하므로 별도 최소권한 Role 접근을 구성해도 된다. 사용자 암호 방식이 유일한 정답은 아니다.

다른 계정에서 기존 정책 JSON을 사용한다면 `067518846638`가 들어간 리소스 ARN을 새 계정 ID로 수정하고 다시 검증해야 한다. 기존 계정 크레딧이 새 계정에 이전되거나 새 프리 티어 자격이 제공된다고 보장하지 않는다. 신규 계정 생성은 별도 사용자 결정 사항이다.

### 경로 2. 현재 프로젝트 환경을 고급 기능 활성화 후 Role 방식으로 구성

계정 전환의 비용·비가역성을 수용하는 경우 검토할 수 있는 공식 경로다. 단순 유료 전환만으로 완료되는 것은 아니다.

큰 흐름:

1. 현재 플랜·크레딧·결제·리소스와 spend limit 제거 영향을 확인한다.
2. 사용자 동의와 직접 조작으로 업그레이드 및 고급 기능 활성화를 진행한다.
3. 별도 실습 IAM Role을 만들고 실습 정책만 연결한다. 기존 AccountFullAccessRole의 AdministratorAccess를 삭제하거나 대체하지 않는다.
4. Account access manager의 애플리케이션·계정 정보를 확인하고, 공식 절차에 맞는 Role 신뢰 관계를 구성한다.
5. IAM Identity Center의 사용자/그룹, 대상 계정, 해당 Role을 매핑한다.
6. 해당 Role로 콘솔 접근하고 서울 리전 사용 가능 여부를 확인한다. 조직 정책의 RegionFloor 등 필요한 제약도 검토한다.
7. 그 뒤 실습 리소스를 생성한다.

고급 기능 안내는 AWS Settings에서 사용자 지정 Role을 접근하려면 Role의 세션 길이를 12시간으로 설정하라고 명시한다. 이는 모든 일반 Role에 공통으로 필요한 설정이 아니라 이 Settings 접근 경로에 관한 안내다.

Account access manager 공식 문서:
- https://docs.aws.amazon.com/IAM/latest/UserGuide/account-access-manager.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/aam-prepare-roles.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/aam-assign-remove-access.html

신뢰 정책의 서비스 주체는 `account-access.amazonaws.com`이며, 공식 준비 문서는 `sts:AssumeRole`, `sts:SetContext`와 함께 `aws:SourceAccount`, `aws:SourceArn` 조건으로 대상 계정·애플리케이션을 제한하도록 안내한다. 기존 관리 역할의 조건 없는 신뢰 정책을 그대로 복사하는 방식으로 설명하지 않는다. 신뢰 정책만 만들어도 사용자에게 Role 접근이 배정되는 것은 아니다.

이 경로는 비용/조직 설정 검토가 필요하므로 아직 실행 단계가 아니다. 고급 기능 활성화가 기존 프로젝트 IAM 사용자 암호 로그인을 자동으로 가능하게 한다고 보장하지 않으며, 여기서는 공식적으로 설명된 사용자 지정 Role 접근 방식을 권장한다.

### 경로 3. 현재 환경 유지와 과제 조건 조정 승인

유료 전환이나 다른 계정 사용을 원하지 않으면 담당자에게 다음 두 제한을 제시해 대체 환경 또는 조건 조정 가능 여부를 문의한다.

- 신규 기본 환경은 IAM 사용자/Role의 별도 콘솔 접근에 제한이 있음.
- 한국 기반 프로젝트 리전은 시드니이며 과제는 서울을 요구함.

CLI로 최소권한 사용자를 사용하거나 시드니에 배포하는 것이 기술적으로 가능할 수 있어도, 담당자 승인 없이 기존 명세를 충족했다고 기록하면 안 된다.

## 4. 현재 상태 및 권고

완료:
- IAM 사용자 `forB3-1` 생성.
- `B3Ec2SeoulLabPolicy` 생성·직접 연결.
- 정책 린터 보안/오류/경고/추천 0 확인.
- 관련 화면과 근거 기록.

미완료:
- 과제용 별도 최소권한 주체의 콘솔 로그인.
- 현재 환경에서 서울 리전 사용.
- 실제 작업으로 정책 검증.

추가 액세스 키 발급이나 기존 관리자 Role 변경은 권고하지 않는다. 과제 리소스를 만들기 전에 사용할 계정 경로를 결정해야 한다. 먼저 기존 일반 계정/적합한 교육 계정이 있는지 확인하고, 없다면 현재 환경의 전환과 비용 영향을 검토하는 순서가 합리적이다.

## 5. 문서 간 주의할 점

https://docs.aws.amazon.com/signin/latest/userguide/introduction-to-iam-user-sign-in-tutorial.html 의 상단은 IAM 사용자 로그인 방식을 advanced 가입 계정에서 지원한다고 설명하지만, 하단에는 신규 경험 로그인 UI를 사용하는 단계가 함께 있어 문구상 혼동의 여지가 있다. 이를 근거로 현재 신규 프로젝트 계정에서 콘솔 IAM 사용자를 생성할 수 있다고 결론 내리지 않는다. 계정 가입 방식과 로그인 페이지 UI의 차이를 고려하고, 현재 계정의 제약은 명확한 IAM 사용자 생성 문서·가입 방식 비교 문서·실제 화면을 우선 근거로 삼았다.

관련 자료:
- [IAM 정책 설계](0014-iam-policy-design.md)
- [화면 관찰 및 실제 생성 기록](0013-iam-user-creation-walkthrough.md)
- [과제 명세](../instruction.md)
