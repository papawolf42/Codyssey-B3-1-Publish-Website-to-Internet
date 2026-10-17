# 0014. B3-1 IAM 정책 설계와 권한별 근거

작성일: 2026-10-17 (한국 시간)

## 1. 결과물과 현재 상태

- AWS 입력용 JSON: [b3-1-ec2-seoul-policy.json](policies/b3-1-ec2-seoul-policy.json)
- 학습용 주석본: [b3-1-ec2-seoul-policy.annotated.jsonc](policies/b3-1-ec2-seoul-policy.annotated.jsonc) — 36개 작업 각각의 옆에 명세 항목·문구 및 요구 구현/방식 선택/콘솔 조회/조건부 정리 구분을 기록했다. JSONC는 주석이 있는 설명용 파일이므로 AWS에는 주석 없는 JSON을 사용한다. 주석 제거 후 원본 정책과 일치하는지 검사했다.
- 요구사항 원문: [instruction.md](../instruction.md)
- 화면 조작 기록: [0013. IAM 사용자 생성 과정](0013-iam-user-creation-walkthrough.md)
- 권장 정책 이름: `B3Ec2SeoulLabPolicy` (아직 AWS에 등록하지 않음)

**최신 상태(2026-10-17): AWS 편집기에 이 JSON을 입력하고 보안·오류·경고·추천 모두 0을 확인했다. `B3Ec2SeoulLabPolicy` 정책 및 `forB3-1` 사용자를 생성했고 정책 한 개가 직접 연결된 것을 확인했다. 실제 리소스 작업·콘솔 로그인·서울 리전 사용은 아직 검증하지 않았다. [완료 기록과 캡처](0013-iam-user-creation-walkthrough.md#16-json-입력정책-생성사용자-생성-및-연결-완료)를 참고한다. 아래 적용 절차와 초안 관련 표현은 최초 설계 당시 기준이며, 최신 적용 결과는 이 문단이 우선한다.**

JSON 구문, 중복 작업, AWS 공식 EC2 권한표에 작업 이름이 존재하는지와 주요 작업의 지원 리소스 유형을 점검했다. 총 7개 문, 중복 없는 36개 작업이며 공백 제외 JSON 길이는 3,655자다. IAM 관리형 정책의 6,144자 한도 이내다. 이는 AWS 정책 검증이나 실행 성공을 대신하지 않는다.

## 2. 과제가 요구하는 것과 우리가 선택한 것

### 과제의 요구

`instruction.md`의 네트워크·컴퓨트·접근 제어·IAM 최소권한·운영 안정성 항목을 근거로 한다.

- VPC, Public Subnet, Internet Gateway, Route Table을 구성한다.
- EC2 1대를 실행하고 SSH로 접속해 웹 서버를 설치한다.
- HTTP 80은 전체 공개, SSH 22는 개인 IP 또는 지정 IP 대역만 허용한다.
- EC2/VPC/Security Group 실습에 필요한 범위로 IAM 권한을 제한한다.
- AdministratorAccess 및 무관한 S3/RDS 등의 권한을 부여하지 않는다.
- 서울 리전에서 구성하며 종료 후 EC2/EBS/네트워크 등 생성한 리소스를 정리한다.

과제는 IAM 작업 이름을 하나씩 지정하지 않는다. 따라서 이 정책은 유일한 정답이나 절대적인 최솟값이 아니라, 아래 구현 방식에 맞춘 작업 허용 목록이다.

### 이번 설계가 전제하는 진행 방식

- 직접 만든 VPC에 Public Subnet 1개, 별도 Route Table 1개를 구성한다.
- EC2에 자동 할당 퍼블릭 IPv4를 사용한다. Elastic IP는 할당하지 않는다.
- 공식 배포자의 일반 Ubuntu/Amazon Linux AMI를 사용한다. Marketplace 유료 AMI는 사용하지 않는다.
- 일반 온디맨드 인스턴스 및 기본 EBS 루트 볼륨을 사용한다.
- AWS에서 새 키페어를 만들고 로컬 SSH 클라이언트로 접속한다.
- 인스턴스에 IAM Role/Instance Profile을 붙이지 않는다.
- NAT Gateway, ALB, RDS, S3, SSM, EC2 Instance Connect, Launch Template, Spot은 사용하지 않는다.
- 태그는 `Name`, `Project` 두 키만 사용한다. 예: `Project=B3-1`. 현재 정책은 Project 태그 부착이나 특정 값을 강제하지 않는다.
- 인스턴스 시작 시 퍼블릭 IP 자동 할당을 명시적으로 켠다. 서브넷 기본값을 수정하는 방식이 아니므로 `ModifySubnetAttribute`는 포함하지 않는다.

**자동 할당 퍼블릭 IPv4나 EC2/EBS가 무료라는 뜻은 아니다. 현재 플랜의 서울 리전 사용 가능 여부, 프리 티어 적용 조건과 실제 비용은 실행 전에 확인한다.**

## 3. JSON의 각 필드 읽는 법

- `Version`: IAM 정책 언어 버전이다. 작성 날짜가 아니며 `2012-10-17`을 사용한다.
- `Statement`: 권한 규칙들의 배열이다. 이 정책에는 목적별로 7개가 있다.
- `Sid`: 문 식별자다. 사람이 구분하기 위한 이름이며, 바꾼다고 권한이 달라지지 않는다.
- `Effect: Allow`: 조건을 만족할 때 지정 작업을 허용한다.
- `Action`: 허용하는 AWS 작업이다. VPC와 보안 그룹도 `ec2:` API 영역에 속한다.
- `Resource`: 그 작업의 대상 리소스다. 빈 배열은 사용하지 않는다.
- `Condition`: 요청 리전이나 태그 키 등 추가 조건이다.

IAM 정책에 `Principal`은 넣지 않는다. 이 파일은 사용자/Role에 연결할 자격 증명 기반 권한 정책이며, Role의 신뢰 정책이 아니다.

## 4. 권한별로 왜 필요한가

### 4.1 B3ReadSeoul: 콘솔에서 목록·상태 확인 (13개)

이 부분은 콘솔 중심 실습을 위한 기본 조회 목록이다. 모든 항목이 과제에 직접 명시된 필수 API는 아니며, 콘솔의 모든 화면이 완전히 동작한다고 보장하는 목록도 아니다. 관련 없는 부가 위젯이 AccessDenied를 표시하면 먼저 무시 가능한지 판단한다.

- `DescribeVpcs`: VPC 목록, ID, CIDR와 상태 확인.
- `DescribeSubnets`: 서브넷의 VPC·가용 영역·CIDR 확인.
- `DescribeInternetGateways`: 인터넷 게이트웨이와 VPC 연결 상태 확인.
- `DescribeRouteTables`: 서브넷 연결 및 `0.0.0.0/0 → IGW` 경로 확인.
- `DescribeSecurityGroups`: 인바운드/아웃바운드 규칙 확인.
- `DescribeAvailabilityZones`: 서브넷을 만들 가용 영역 선택.
- `DescribeImages`: EC2의 OS 이미지(AMI) 선택.
- `DescribeInstanceTypes`: 선택할 인스턴스 타입의 사양 확인.
- `DescribeKeyPairs`: SSH 키페어 선택 및 정리 결과 확인.
- `DescribeInstances`: 인스턴스 ID·상태·퍼블릭 IP·연결 리소스 확인.
- `DescribeInstanceStatus`: 인스턴스 상태 검사 확인.
- `DescribeVolumes`: 루트 EBS와 종료 후 남은 볼륨 확인.
- `DescribeNetworkInterfaces`: EC2 네트워크 연결 및 삭제 의존성 확인.

이들 조회 작업은 개별 리소스 ARN 단위 제한을 지원하지 않으므로 `Resource: "*"`를 사용한다. 대신 작업 이름을 열거하고 요청 리전을 서울로 제한한다. `Describe*` 전체 허용은 사용하지 않는다. 조회 범위에는 접근 가능한 이미지 등의 정보도 포함될 수 있다.

### 4.2 B3NetworkSetup: 네트워크 생성·연결·규칙 설정 (9개)

- `CreateVpc`: 과제의 격리된 VPC 생성.
- `CreateSubnet`: VPC 안에 Public Subnet 생성. Public 여부는 이 작업명만으로 결정되지 않고 라우팅과 IP 설정으로 완성된다.
- `CreateInternetGateway`: 인터넷 출입구 생성.
- `AttachInternetGateway`: 생성한 인터넷 게이트웨이를 VPC에 연결.
- `CreateRouteTable`: 별도 라우팅 테이블 생성. VPC의 기본 테이블을 쓰는 다른 설계라면 줄일 수 있지만, 이번에는 명시적인 별도 테이블을 사용한다.
- `AssociateRouteTable`: 서브넷이 사용할 라우팅 테이블 연결.
- `CreateRoute`: 인터넷으로 가는 기본 경로 추가.
- `CreateSecurityGroup`: 실습용 보안 그룹 생성.
- `AuthorizeSecurityGroupIngress`: HTTP·SSH 인바운드 허용 규칙 추가.

대상 ARN은 현재 계정의 서울 리전 VPC·서브넷·IGW·Route Table·Security Group·Security Group Rule 유형으로 제한한다. 생성되는 리소스 ID를 아직 모르므로 ID 자리에 `*`를 쓴다. 일부 API는 여러 리소스를 함께 검사하므로 유형별 ARN을 함께 제공한다. 규칙에 태그를 붙이는 요청을 고려해 `security-group-rule`도 포함했다.

**이 권한은 인바운드 규칙을 추가할 수 있게 할 뿐, 80/22 포트나 SSH 개인 IP 제한 자체를 강제하지 않는다.** 실제 보안 그룹 구성 때 요구사항에 맞춰 설정하고 별도로 검증한다.

### 4.3 B3NetworkCleanup: 네트워크 정리 (8개)

- `DeleteSecurityGroup`: EC2의 의존성이 사라진 뒤 실습 보안 그룹 삭제.
- `DeleteRoute`: 직접 추가한 인터넷 기본 경로 제거. 테이블 자체 삭제로 함께 제거할 수도 있어 모든 정리 경로에서 필수는 아니지만, 이번 명시적 역순 정리 방식에 포함했다.
- `DisassociateRouteTable`: 서브넷과 별도 테이블의 연결 해제.
- `DeleteRouteTable`: 직접 만든 별도 테이블 삭제.
- `DetachInternetGateway`: VPC에서 인터넷 게이트웨이 분리.
- `DeleteInternetGateway`: 분리된 게이트웨이 삭제.
- `DeleteSubnet`: EC2/ENI 의존성이 사라진 서브넷 삭제.
- `DeleteVpc`: 나머지 의존 리소스를 정리한 VPC 삭제.

대상은 서울 리전의 해당 계정 네트워크 유형이다. 기본 Route Table이나 기본 Security Group은 개별 삭제하지 않고 VPC 삭제 과정에서 함께 정리되는 항목을 구분한다.

### 4.4 B3SshKeyLifecycle: SSH 접속 준비와 키 정리 (2개)

- `CreateKeyPair`: 이번 실습에서 AWS가 키페어를 생성하고 개인 키를 내려받는 방식을 선택했기 때문에 포함했다.
- `DeleteKeyPair`: 사용 후 AWS에 등록된 키페어 삭제.

키페어 삭제는 서버의 `authorized_keys`나 로컬 개인 키를 지우는 작업이 아니다. 서버 종료 및 로컬 개인 키의 안전한 보관/폐기는 별도다. 개인 키는 Git·문서·스크린샷에 기록하지 않는다. SSH 자체는 이 정책의 IAM API가 아니라 개인 키, 네트워크, OS 로그인 계정으로 인증한다.

### 4.5 B3LaunchInstance: EC2 생성·실행 (1개)

- `RunInstances`: EC2 1대를 최초 생성하고 실행한다.

이 API는 인스턴스만 검사하지 않고 AMI, 서브넷, 보안 그룹, ENI, EBS, 키페어 등의 리소스를 함께 검사한다. 따라서 인스턴스 ARN 하나만 넣으면 부족하다.

- AMI: `arn:aws:ec2:ap-northeast-2::image/*` (공식 리소스 ARN 형식에서 계정 부분이 비어 있음)
- 그 외: 현재 계정·서울 리전의 `instance`, `network-interface`, `security-group`, `subnet`, `volume`, `key-pair` 유형

AMI와 서브넷 ID가 확정되면 해당 ARN을 정확한 ID로 좁힐 수 있다. 현재는 특정 AMI 배포자·이미지 ID를 강제하지 않는다. 일반적인 공식 이미지/기본 EBS 구성 기준이며 고객 관리 KMS 키, Role, Launch Template 등의 기능을 추가하면 별도 검토가 필요하다.

### 4.6 B3ComputeCleanup: 인스턴스·잔여 볼륨 정리 (2개)

- `TerminateInstances`: EC2를 중지가 아닌 종료 상태로 만들기.
- `DeleteVolume`: 종료 후 남은 미연결 EBS가 있다면 삭제하기. 자동 삭제된 볼륨에는 실행할 일이 없다.

`DeleteVolume`만으로 연결된 볼륨을 삭제할 수는 없다. 이 실습에서는 인스턴스를 종료한 뒤 잔여 볼륨을 정리하므로 `DetachVolume`은 포함하지 않는다.

### 4.7 B3ResourceLabels: 실습 리소스 구분 (1개)

- `CreateTags`: 생성 시 또는 생성 후 이름·프로젝트 태그를 추가하거나 덮어쓰기.

이름 태그 자체가 과제 필수 API는 아니지만 실습 대상과 정리 대상을 식별하기 위해 선택한 방식이다. 태그가 있는 생성 요청의 종속 권한으로도 필요할 수 있다.

허용 태그 키를 `Name`, `Project`로 제한했다. 다른 키를 포함한 요청은 이 문으로 허용되지 않는다. `Null` 조건은 태그 키가 있는 요청을 요구하며, `ForAllValues:StringEquals`는 요청한 모든 키가 허용 목록 안에 있는지 검사한다. 특정 태그 값이나 `Project=B3-1` 부착을 강제하는 조건은 아니다.

## 5. 최소권한의 범위와 한계

### 줄인 범위

- EC2 API 영역의 36개 작업만 열거한다. `ec2:*`, `Describe*`, AdministratorAccess를 사용하지 않는다.
- S3/RDS/IAM 관리/SSM/ELB/NAT/EIP 조작 권한을 부여하지 않는다.
- 모든 문에 `aws:RequestedRegion=ap-northeast-2` 조건을 둔다.
- 변경 작업은 현재 계정 `067518846638`의 서울 리전 관련 리소스 유형으로 제한한다. AMI는 공식 ARN 형식의 예외다.
- 태그 키를 Name/Project로 제한한다.

### 아직 강제하지 않는 범위

- 유형별 ARN의 ID가 `*`이므로 **같은 계정·서울 리전의 기존 해당 유형 리소스도 수정/삭제할 수 있다. 실습 리소스만 격리된 정책은 아니다.** 공유/운영 계정에는 그대로 적용하지 않는다.
- 인스턴스 1대, micro 타입, EBS 용량, 유료 AMI 배제, 퍼블릭 IP 비용이나 총 지출 한도를 IAM으로 강제하지 않는다. 실행 전 별도 확인이 필요하다.
- SSH 소스 IP/포트 제한을 이 IAM 정책으로 강제하지 않는다.
- 선택한 허용 목록 밖의 권한을 이 파일이 새로 허용하지 않을 뿐, 다른 정책의 허용을 취소하지는 않는다. 서울 외 리전도 명시적 Deny가 아니라 이 정책에서 Allow를 주지 않는 방식이다.
- 현재 계정 ID는 열린 AWS 콘솔 URL을 근거로 넣었다. 다른 계정에서는 수정해야 한다.

더 엄격하게 하려면 생성 전 RequestTag 요구, 생성 후 ResourceTag 조건, 확정된 VPC/Subnet/AMI/키페어 ARN 및 인스턴스 타입 조건 등을 작업별 지원 범위에 맞춰 설계해야 한다. 자동 생성되는 기본 리소스의 태그, 생성과 조회의 차이 때문에 일괄 태그 조건을 붙이면 정리가 막힐 수 있다. 현재 문서는 그 수준까지 구현했다고 주장하지 않는다.

## 6. 제외한 권한과 이유

- Start/Stop/RebootInstances: 최초 실행→웹 서버 배포→검증→종료 경로에 필수 아님.
- ModifyVpcAttribute/ModifySubnetAttribute: 기본 DNS 설정을 유지하고 인스턴스 실행 때 퍼블릭 IP를 켜는 방식. 변경 필요성이 확인되면 재검토.
- RevokeSecurityGroupIngress: 최초 올바른 규칙 추가와 그룹 삭제만 수행하는 기본 경로에서는 제외. 오류 규칙을 제거해야 한다면 근거를 남기고 추가 검토.
- Authorize/RevokeSecurityGroupEgress: 새 그룹의 기본 아웃바운드를 유지하는 방식이므로 제외.
- iam:PassRole 및 IAM 생성/연결 권한: 인스턴스에 Role을 붙이지 않고, 실습 사용자가 자기 권한을 관리하지 않으므로 제외.
- EC2 Instance Connect/SSM: 로컬 SSH 방식이므로 제외.
- Elastic IP 관련 작업: 자동 할당 IP를 사용하므로 제외. 별도로 EIP를 만들면 이 정책으로 정리할 수 없다.
- CreateVolume/AttachVolume/DetachVolume: 별도 데이터 볼륨을 만들지 않고 RunInstances의 루트 EBS를 사용하므로 제외.
- 나머지 조회 작업: 실제 과제 흐름에서 필요하다고 확인되면 최소 추가.

## 7. 적용 및 검증 절차

1. 현재 프로젝트에서 별도 IAM 사용자/Role의 콘솔 접근 방식과 서울 리전 사용 가능 여부를 먼저 확인한다. 사용자 생성 화면에는 프로그래밍 접근 안내만 있었고, 이 문제는 해결된 것으로 간주하지 않는다. 정책을 만들었다고 로그인 방식이 생기는 것은 아니다.
2. JSON 파일 전체를 정책 편집기에 넣는다. 이 문서를 작성하는 동안 실제 입력은 하지 않았다.
3. 편집기의 오류·경고·추천을 확인하고, 오류는 원인을 해소하기 전 생성하지 않는다.
4. 정책 이름과 내용을 검토한 뒤 사용자의 확인을 받고 생성·연결한다. 다른 관리형 정책·그룹·인라인 정책이 부여하는 권한도 함께 확인한다.
5. 별도 실습 주체로 서울 리전에서 필요한 작업만 실행하며 검증한다. 정책 시뮬레이터 또는 실제 AccessDenied 기록으로 보완할 수 있다. SCP·권한 경계·세션 정책 등의 제약도 영향을 준다.
6. AccessDenied가 나오면 실패한 작업, 리소스, 시각, 화면을 기록한다. 과제에 필요한 작업인지 판단한 후 최소 범위로 보완한다. 전체 EC2 권한을 붙여 우회하지 않는다.
7. 실제로 생성한 리소스 ID를 정리 목록에 기록하고 정책을 추가로 좁힐 수 있는지 검토한다.
8. EC2 종료, 잔여 EBS, 네트워크 역순 정리 후 리소스 목록과 비용 화면을 확인한다. Billing 조회 권한은 이 실습 정책에 포함하지 않았으므로 별도 권한이 있는 관리자 주체에서 확인한다.

## 8. 참고 자료

- [프로젝트 공식 요구사항 정리](../instruction.md)
- [AWS: EC2 작업·리소스·조건 키](https://docs.aws.amazon.com/service-authorization/latest/reference/list_ec2.html) — 2026-10-17 작업 이름과 주요 리소스 지원 유형 확인. 과거 list_amazonec2.html 주소는 확인 시 인덱스로 이동하여 현재 list_ec2.html을 사용했다.
- [AWS: VPC와 IAM의 관계](https://docs.aws.amazon.com/vpc/latest/userguide/security_iam_service-with-iam.html)
- [AWS: EC2 권한표와 RunInstances의 다중 리소스 평가 설명](https://aws.amazon.com/blogs/security/can-i-do-that-with-policy-understanding-the-aws-service-authorization-reference/)

정책 구문/참조 점검과 AWS에서의 실제 권한 검증은 다르다. AWS 린터 검사·정책 생성·사용자 직접 연결은 완료했지만, 실제 리소스 작업을 통한 권한 검증은 아직 하지 않았다.

## 9. 질문: 권한이 36개인데 최소권한인가?

개수만으로 판단할 수 없다. 이 정책은 서비스와 작업을 좁힌 실습용 초안이며, 절대 최소 권한으로 검증된 정책은 아니다. 조회 13개, 네트워크 설정 9개, 네트워크 정리 8개, 키페어 2개, EC2 실행 1개, 컴퓨트 정리 2개, 태그 1개를 포함한다.

필요한 작업도 구현 방식에 따라 달라진다. 예를 들어 별도 Route Table을 생성하지 않으면 CreateRouteTable을 줄일 수 있고, 생성한 테이블 자체를 삭제하면 DeleteRoute가 별도로 필요하지 않을 수도 있다. 콘솔 조회와 Name/Project 태그는 과제가 모든 API를 직접 요구한 것이 아니라 선택한 학습/운영 방식에 따른 권한이다.

특히 Resource의 ID가 *인 변경 권한은 실습 리소스에만 격리되지 않았다. 따라서 “36개 모두 명세가 요구한 최소 API이고, 실습 리소스에만 제한된 완성 정책”이라고 설명해서는 안 된다. JSONC 주석본에서 이 구분을 각 작업 옆에 확인할 수 있다. AWS 정책 생성·사용자 직접 연결은 후속 진행으로 완료했지만 실제 동작 검증은 아직 미완료다.
