# 서울 실습 네트워크 구성 진행

[이전: IAM 콘솔 로그인과 MFA](0018-iam-console-login-and-mfa.md) · [트러블슈팅](troubleshooting.md)

## 1. 기존 VPC 확인

실습 계정 067518846638, IAM 사용자 forB3-1, 서울(ap-northeast-2)에서 VPC 목록을 확인했다.

- 기존 VPC: vpc-0f2817bf8e55c5af4
- IPv4 CIDR: 172.31.0.0/16
- 상태: Available
- 기본 VPC: 예
- 기본 라우팅 테이블: rtb-044f497d7d18b2eb0

이것은 기존 기본 VPC이며 과제에서 새로 생성한 자원이 아니다. 삭제·수정하지 않는다. 전용 실습 VPC를 별도로 구성할 예정이다. 현재 새 리소스는 생성하지 않았다.

![기존 기본 VPC와 조회 알림](captures/0074-vpc-list-before-lab.png)

## 2. 동반 권한 오류

VPC 목록은 정상 표시되지만 알림에 ec2:DescribeAccountAttributes 작업을 허용하는 identity-based policy가 없다는 오류가 표시된다. 앞선 SCP 명시적 거부와 원인이 다르다. 이는 현재 사용자 정책에서 해당 조회를 허용하지 않는다는 증거이며 VPC 목록 전체의 조회 실패는 아니다. 다른 알림의 상세는 아직 확인하지 않았다. 필요한 과제 작업이 실제로 막히면 해당 API와 필요한 최소 범위를 검토하고 기존 관리자 역할은 변경하지 않는다.

## 다음 단계

VPC 생성 화면을 열어 구성 옵션을 확인한다. 생성 전 이름·CIDR·태그·비용 발생 가능 옵션을 확인하고 실제 생성은 사용자가 직접 수행한다. NAT Gateway·유료 엔드포인트 등 불필요한 자원을 자동 생성하지 않도록 주의한다.


## 3. 추가 오류 확인을 우선함

사용자가 다른 오류도 있다고 지적했다. 처음 알림 집계는 3건이었고, 후속 화면에서 네트워크 ACL 조회 ec2:DescribeNetworkAcls도 identity-based policy의 허용 부재로 거부된 것을 확인했다. 앞서 계정 속성 오류만 설명한 것은 전체 알림을 확인한 것이 아니었다. 생성 진행을 잠시 멈추고 View all notifications로 전체 오류를 확인하기로 했다. 아직 모든 오류의 API를 확인하지 않았고 권한 변경은 하지 않았다.

![네트워크 ACL 조회 권한 오류](captures/0075-vpc-additional-errors.png)


## 4. VPC 단독 생성 설정 화면

VPC 생성 화면에서 `VPC만`, IPv4 CIDR 수동 입력, IPv6 없음, 기본 테넌시가 선택된 것을 확인했다. 아직 이름과 CIDR은 입력되지 않았다. 권한 정책 파일의 CreateVpc 및 Name/Project 태그 허용 범위를 확인했다.

제안 구성: Name=b3-1-vpc, IPv4 CIDR=10.0.0.0/16, IPv6 없음, 기본 테넌시. VPC만 생성하고 서브넷·IGW·라우팅 테이블은 별도 단계로 구성해 각각 역할을 학습한다. 이 제안은 실제 생성 완료가 아니다. NAT Gateway나 유료 엔드포인트를 함께 생성하는 방식은 사용하지 않는다.

![VPC 단독 생성 설정 화면](captures/0076-vpc-create-options.png)


## 5. 생성 직전 입력값 확인

사용자가 입력한 값이 Name=b3-1-vpc, IPv4 CIDR=10.0.0.0/16, VPC만, IPv6 없음, 기본 테넌시임을 확인했다. 태그도 Name=b3-1-vpc 한 개다. 기존 기본 VPC의 172.31.0.0/16과 겹치지 않는다. 이 화면에서 아직 생성 완료는 아니며 사용자가 최종 VPC 생성 버튼을 누르는 단계다.

![VPC 생성 직전 설정](captures/0077-vpc-ready-to-create.png)


## 6. VPC 생성 성공과 상세 화면 조회 오류

사용자가 최종 생성 버튼을 눌렀고 AWS 성공 알림 `vpc-062ac6fd0606192ab / b3-1-vpc 생성됨`을 확인했다. 최소권한 사용자 forB3-1, 서울 리전에서 실제 VPC 생성이 수락됐다. 새 VPC ID는 vpc-062ac6fd0606192ab다.

동시에 상세 화면에서 ec2:DescribeNatGateways와 ec2:DescribeNetworkAcls의 identity-based policy 허용 부재가 표시됐다. 생성 실패가 아니라 생성 후 상세 리소스 로딩 실패로 구분한다. 재생성하지 않는다. 다음은 VPC 목록으로 돌아가 새 VPC를 확인하고, 콘솔 실습에 필요한 조회 권한 보완 범위를 검토하는 단계다. 기존 관리자 역할은 수정하지 않는다.

![VPC 생성 성공 및 부가 조회 오류](captures/0078-vpc-creation-result.png)

정리 대상에 추가: 사용자 생성 VPC vpc-062ac6fd0606192ab. 의존 리소스 정리 후 삭제하며, 기존 기본 VPC vpc-0f2817bf8e55c5af4는 삭제 대상이 아니다.


## 7. 두 조회 오류의 직접 원인 재확인

현재 화면을 다시 읽어 다음 두 오류와 생성 성공 알림이 동시에 표시됨을 확인했다.

- ec2:DescribeNatGateways: NAT Gateway 현황 조회. identity-based policy에 이 작업의 Allow가 없어서 거부됐다.
- ec2:DescribeNetworkAcls: 서브넷 경계 Network ACL 현황 조회. 같은 허용 부재로 거부됐고, VPC 상세 화면 전체의 로딩 오류에도 표시된다.

두 오류는 VPC 생성이 취소되거나 ACL 트래픽 처리 자체가 정지됐다는 의미가 아니다. 생성 성공과 상세 조회 성공은 다른 API·권한이다. NAT를 생성하지 않는 설계라도 콘솔은 리소스 현황을 조회할 수 있다. 예전 p-l9spe88l SCP의 explicit deny 오류와 이번 identity-based policy 허용 부재를 구분한다.

조치 후보는 실습 콘솔에 필요한 두 Describe 작업을 기존 B3ReadSeoul 조회 문장에 추가해 서울 리전 조건과 Resource=*를 유지하는 것이다. 조회 권한을 추가하는 것이 NAT/ACL 생성·수정 권한을 주는 것은 아니다. 실제 연결 정책 버전을 다시 확인하고 사용자 승인 후 직접 변경·재조회 검증해야 한다. 아직 이 조회 권한을 변경하지 않았다.

![현재 두 조회 권한 오류](captures/0079-vpc-two-read-errors.png)

쉬운 설명은 aside-bridge에 별도 작성 요청했다. 검수 후 [질문 해설 문서](0021-vpc-read-errors-쉬운설명.md)와 연결한다. 원본과 해설의 파일 소유권을 나눠 동시에 같은 문서를 수정하지 않는다.


## 8. 과제 범위 정정 및 서브넷 목록 확인

명세에는 Network ACL 직접 설정이나 NAT Gateway 생성이 필수로 요구되지 않는다. 상세 화면 조회 편의를 위해 IAM 권한을 보완하자는 제안은 과제 필수 조건과 구분한다. 사용자는 추가 조회 권한을 부여하지 않고 필수 네트워크 구성을 계속하기로 했다. TS-003 조회 오류는 미해결 상태로 남겨 두며, 후속 필수 작업이 실제로 막힐 경우에만 필요한 범위를 재검토한다.

서브넷 목록에는 기존 기본 VPC(vpc-0f2817bf8e55c5af4) 소속 기본 서브넷 4개가 표시된다. 새 실습 VPC에 직접 생성한 서브넷은 이 목록에서 아직 확인되지 않았다. DescribeNetworkAcls 알림은 남아 있지만 서브넷 목록은 표시된다. 목록의 Last updated가 약 2시간 전이므로 개수와 항목은 현재 화면에 표시된 결과로 기록한다. 다음 단계는 서브넷 생성 화면을 열어 b3-1-vpc를 선택하는 것이다. 실제 생성은 아직 수행하지 않았다.

![기존 기본 서브넷 4개 및 ACL 조회 알림](captures/0080-subnet-list-before-lab.png)


## 9. Network ACL 요금과 NAT 위치 구분

AWS 공식 VPC Network ACL 문서는 network ACL 사용에 추가 요금이 없다고 명시한다. AWS WAF의 Web ACL은 다른 기능이며 Web ACL·규칙·요청 기준으로 과금한다. 사용자가 들은 유료 ACL이 어느 제품이었는지는 확인하지 않았다. NAT Gateway는 별도의 시간·데이터 처리 요금이 있는 서비스다. VPC Network ACL과 이름이 비슷하다고 WAF Web ACL 또는 AWS Network Firewall의 요금을 혼동하지 않는다.

개념도는 공용 NAT Gateway의 일반적인 배치를 뜻해야 한다. NAT는 퍼블릭 서브넷 안의 주소 변환 서비스이고, ACL은 서브넷 경계의 필터, SG는 네트워크 인터페이스에 연결하는 보안 규칙이다. 이를 단순한 상하 방화벽 레이어로 표현하지 않는다. 이번 실습은 NAT를 사용하지 않는 public EC2 + IGW 설계다.

공식 근거:
- https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
- https://aws.amazon.com/waf/pricing/
- https://aws.amazon.com/vpc/pricing/
