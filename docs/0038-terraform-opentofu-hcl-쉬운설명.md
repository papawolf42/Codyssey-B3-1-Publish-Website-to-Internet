# Terraform·OpenTofu 차이와 설정 작성 방법

[이전: 다양한 배포 방법](0037-deployment-methods-선택지.md)

## 1. IaC, 도구, 언어를 구분하기

- **IaC**: Infrastructure as Code. 인프라를 코드로 정의·관리하는 접근 방식.
- **Terraform / OpenTofu**: 그 접근 방식을 구현하는 도구.
- **HCL 기반 Terraform 구성 문법**: 원하는 인프라를 작성하는 기본 문법. 보통 `.tf` 파일에 쓴다.

따라서 IaC와 HCL은 같은 종류의 개념이 아니다. “IaC 이외의 방법으로 Terraform을 설정”보다는 “HCL 이외의 형식으로 Terraform 구성을 작성할 수 있나?”를 구분해서 질문하면 명확해진다.

## 2. Terraform과 OpenTofu

### Terraform

HashiCorp에서 시작한 인프라 관리 도구다. 최근 버전은 Business Source License 1.1(BSL/BUSL)을 사용한다. 소스 코드를 볼 수 있지만 OSI식 오픈소스와 동일한 라이선스는 아니다. 일부 경쟁 서비스 제공 등에는 제한이 있다. 이것을 개인 실습용 CLI가 무조건 유료라는 뜻으로 해석하면 안 된다.

### OpenTofu

Terraform의 라이선스 변경을 계기로 기존 오픈소스 코드를 분기해 독립적으로 개발하는 도구다. Linux Foundation 산하의 커뮤니티 중심 프로젝트이며 MPL 2.0 오픈소스 라이선스를 사용한다.

### 학습할 때 체감하는 차이

둘 다 원하는 인프라를 구성으로 선언하고 상태를 추적하며 변경 계획을 검토한 뒤 적용한다. 기본 구성과 개념이 비슷하다. 실행 명령은 `terraform`과 `tofu`로 다르다.

OpenTofu는 Terraform 구성과의 호환을 목표로 하며 대부분의 기존 구성을 수정 없이 사용할 수 있다고 안내한다. 다만 두 프로젝트가 독립적으로 발전하므로 모든 버전·새 기능·state가 언제나 완전히 호환된다고 보장할 수는 없다. 전환할 때는 버전별 이관 문서, 코드와 state 백업, plan 검증이 필요하다.

초보 학습에서는 둘 중 하나를 선택해 자원·provider·변수·state·plan 개념부터 배우면 된다. 이번 과제에서는 둘 다 같은 AWS 구성 목표에 사용할 수 있지만 현재 IAM 권한이 모든 도구 작업을 허용하는지 별도 검토해야 한다.

## 3. HCL 이외의 Terraform 구성 방법

### 직접 HCL로 작성: `.tf`

사람이 읽고 수정하기 좋은 일반적인 방법이다. 처음 학습하는 경우 이 방식으로 자원 간 관계를 읽는 것을 추천한다.

### JSON으로 작성: `.tf.json`

Terraform이 공식적으로 지원하는 대체 구문이다. HCL 네이티브 구문으로 표현할 수 있는 구성을 JSON 구문으로도 표현할 수 있다. 다만 단순히 아무 JSON이나 읽는 것이 아니라 Terraform 구성의 정해진 JSON 구조여야 한다. 일부 표현은 HCL보다 장황하다.

### 다른 언어로 구성을 생성

Python이나 TypeScript 프로그램이 Terraform 규칙에 맞는 `.tf.json`을 생성하게 만들 수 있다. 이 경우 Terraform이 직접 Python 파일을 인프라 정의로 실행하는 것이 아니라, 생성된 Terraform JSON 구성을 읽는다. YAML을 임의로 작성한다고 Terraform이 바로 인식하는 것도 아니다.

과거에는 CDK for Terraform(CDKTF)이 일반 프로그래밍 언어에서 Terraform 구성을 생성하는 대표적인 도구였다. 하지만 공식 문서 기준 **2025-12-10부터 deprecated이며 HashiCorp가 지원·유지보수하지 않는다.** 새 학습 프로젝트의 기본 선택지로 추천하지 않는다. AWS CDK는 CloudFormation을 사용하는 별도 도구이며 CDKTF와 혼동하지 않는다.

## 4. 'config'가 입력값 설정을 뜻했다면

자원 정의와 입력값도 구분한다. 같은 구성에서 리전·인스턴스 유형 같은 값을 바꾸는 데는 입력 변수, `.tfvars` 파일, 명령행 변수, 환경변수 등을 사용할 수 있다. 이는 HCL/JSON 인프라 정의 자체를 대체하는 별도 엔진이 아니다.

또한 Terraform CLI 자체의 설정이나 AWS 인증 설정은 인프라 자원 정의와 다른 층이다. 자격증명을 구성 파일에 하드코딩하지 않는다.

## 5. 지금 단계의 추천

도구는 Terraform 또는 OpenTofu 중 하나, 구성은 기본 `.tf`로 시작하는 것을 추천한다. 같은 VPC 정의를 `.tf`와 `.tf.json`으로 비교해 보면 '방법 / 도구 / 문법'의 차이를 이해하기 쉽다. 현재 실행 중인 AWS 자원에는 아직 이 도구들을 적용하지 않았으며 새 자원도 만들지 않았다.

## 공식 근거

- Terraform 라이선스: https://github.com/hashicorp/terraform/blob/main/LICENSE
- HashiCorp 라이선스 FAQ: https://www.hashicorp.com/en/license-faq
- OpenTofu 프로젝트·라이선스: https://github.com/opentofu/opentofu
- Linux Foundation 발표: https://www.linuxfoundation.org/press/announcing-opentofu
- OpenTofu 이관 안내: https://opentofu.org/docs/intro/migration/
- Terraform JSON 구성 문법: https://developer.hashicorp.com/terraform/language/syntax/json
- CDKTF 지원 종료 안내: https://developer.hashicorp.com/terraform/cdktf

공식 웹 문서 확인 기준: 이번 질의 응답 시점. 버전·기능·라이선스 조건은 실제 도입 시 해당 버전 문서로 재확인한다.
