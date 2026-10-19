# 원본 EC2·VPC 정리를 위한 IAM 조회 권한 보완

> **정책 버전 관찰 보충:** 이후 사용자 질문으로 기존 관리 역할의 정책 버전 탭을 읽었을 때 기본 버전은 **v7**, 보존 목록은 v3~v7, 편집 시각은 2026-10-19 14:52 KST로 표시됐다. 이는 당시 UI 버전 메타데이터 관찰이며 v7 전체 JSON을 export·대조한 결과는 아니다. 저장소의 기본 JSON 파일은 브라우저 SSH 보완 당시 v3 사본이고 현재 v7을 그대로 담은 최신본이라고 사용하지 않는다. [정책 파일별 범위](policies/README.md).

작성일: 2026-10-19. 최초 제안 이후 사용자가 권한 추가 완료를 보고했다. 후속 `forB3-1`의 EC2 종료 확인창에서 속성 조회 오류가 사라지고 대상 `i-05d34639a30bbfb6a`의 종료 방지 `비활성`이 표시되는 것을 확인했다. `OS 종료 건너뛰기`는 선택되지 않았다. [확인창 증빙](captures/0235-cleanup-ec2-termination-authorized.png).

**전체 6개 작업 목록과 실제 기본 정책 버전 번호까지 별도 재검증한 것은 아니다.** Assistant는 최종 종료 버튼을 누르지 않았고 사용자 직접 실행을 기다리는 단계다. 원본 EC2 종료·VPC 삭제도 아직 완료로 기록하지 않는다. Compute Optimizer의 부가 조회 오류는 종료 방지 조회와 별개다.

[전체 정책 제안본](policies/b3-1-ec2-seoul-policy-v4-cleanup-proposed.json) · [기존 정책 보관본](policies/b3-1-ec2-seoul-policy.json) · [정리 체크리스트](cleanup-checklist.md)

## 실제 확인한 오류

`forB3-1`의 원본 EC2 종료 확인창에서 `ec2:DescribeInstanceAttribute`가 허용되지 않았다는 메시지를 확인했다. 대상은 `i-05d34639a30bbfb6a`였다. 이는 종료 방지 등 인스턴스 속성을 읽는 단계의 거부이며, 이 메시지만으로 `ec2:TerminateInstances` 실행 자체가 거부됐다고 단정할 수 없다. 길게 붙은 Encoded authorization failure message는 이 문서에 복사하지 않았다.

## 기존에 있는 권한

보관된 v3 정책의 `B3ComputeCleanup`에는 `TerminateInstances`, `DeleteVolume`이 있다. `B3NetworkCleanup`에는 다음이 있다.

- `DeleteSecurityGroup`, `DeleteRoute`, `DisassociateRouteTable`, `DeleteRouteTable`
- `DetachInternetGateway`, `DeleteInternetGateway`, `DeleteSubnet`, `DeleteVpc`

현재 IAM 편집기는 해당 정책의 v3 편집 화면이다. 편집기에서 보이는 `B3ReadSeoul`의 조회 목록에도 `DescribeInstanceAttribute`가 없었다. 기존 삭제 권한을 관리자 전체 권한으로 교체할 문제가 아니라 조회 누락을 보완할 상황이다.

## 보완안: B3ReadSeoul의 Action에 6개 추가

- `ec2:DescribeInstanceAttribute`: 종료 방지·연결 디스크 등 EC2 속성 조회.
- `ec2:DescribeVpcAttribute`: VPC DNS 등 속성 조회.
- `ec2:DescribeNetworkAcls`: VPC의 기본/사용자 정의 네트워크 ACL 확인.
- `ec2:DescribeVpcEndpoints`: VPC 삭제를 막는 엔드포인트 유무 확인.
- `ec2:DescribeNatGateways`: NAT Gateway 잔존 여부 확인.
- `ec2:DescribeDhcpOptions`: VPC에 연결된 DHCP 옵션 확인. 공유·기본 옵션을 임의로 삭제하라는 뜻은 아니다.

위 항목은 읽기 권한이며, 새로운 삭제·생성·수정 권한은 추가하지 않는다. 원래의 `Resource: "*"`와 `aws:RequestedRegion: ap-northeast-2` 조건을 유지한다. 전체 제안본은 기존 JSON을 읽어 이 6개만 추가했고 다른 Statement가 바뀌지 않았음을 프로그램으로 검사했다. JSON 파싱 검사도 통과했다. 이는 IAM 저장 또는 실제 권한 동작 검증과는 다르다.

### ARN 제한 안내 정정

앞서 assistant가 이 조회 권한을 해당 인스턴스 ARN에만 제한할 수 있다고 안내했으나, 공식 EC2 Service Authorization Reference의 개별 작업 행을 확인한 결과 `DescribeInstanceAttribute`와 `DescribeVpcAttribute`는 리소스 수준 권한을 지원하지 않았다. 따라서 이 제안에서는 **`Resource: "*"`가 필요하며 서울 리전 조건으로 제한**한다. 오류 메시지에 인스턴스 ARN이 등장한다고 해서 해당 API가 ARN 단위 제한을 지원한다는 뜻은 아니다.

## 지금 추가하지 않는 권한

- `AdministratorAccess`, `ec2:*`, `ec2:Describe*` 같은 광범위 허용.
- 만들어진 것으로 확인하지 않은 NAT Gateway·Endpoint·ELB·RDS 등의 삭제 권한.
- 고아 ENI 강제 삭제·EIP 해제 등 실제 대상이 아직 식별되지 않은 변경 권한.
- 종료 방지 설정을 바꾸는 `ModifyInstanceAttribute`. 현재는 속성 조회 거부만 확인했고, 종료 방지 활성 여부는 미확인이다.
- Compute Optimizer의 부가 화면 오류를 없애기 위한 과제 외 권한.

나중에 실제 정리 대상으로 추가 자원이 확인되면 해당 ID·의존성과 필요한 작업만 별도로 검토한다. VPC 콘솔의 부가 조회 경고가 앞으로 단 하나도 생기지 않는다고 보장하는 정책은 아니다.

## 사용자가 직접 적용할 순서

1. IAM 정책 `B3Ec2SeoulLabPolicy`의 JSON 편집 화면에서 `Sid: B3ReadSeoul`을 찾는다.
2. 기존 Action 목록의 마지막 `ec2:DescribeSecurityGroupRules` 줄 뒤에 쉼표를 넣고 위 6개를 추가한다. Resource와 서울 리전 조건은 그대로 둔다.
3. 또는 전체 정책 제안본을 사용한다. 일부 Action 문자열만 전체 정책으로 붙여 넣지 않는다.
4. JSON 오류가 없는지 보고 검토 화면에서 **조회 권한 6개만 추가되는지** 확인한다.
5. 사용자가 저장한다. 저장 후 기본 버전과 화면의 성공 상태를 확인한다.
6. `forB3-1`의 기존 종료 모달을 취소한 뒤 새로 고침하고 다시 연다. 권한 반영에 잠시 시간이 걸릴 수 있다.
7. 조회 오류가 없어지고 종료 방지가 비활성이며 대상 ID가 맞는지 확인한 뒤, 사용자 확인으로 실제 종료를 진행한다. 다른 오류가 나오면 내용을 확인하고 무조건 권한을 확대하지 않는다.

정책 제안 파일명에 v4가 있어도 실제 AWS 버전 번호가 v4로 저장됐다는 의미는 아니다. 기본 버전과 적용 결과는 저장 후 확인해야 한다.

## 정리 상태 보충

사용자는 현재 Cloudflare A 레코드를 유지하고, 향후 복원한 새 EC2 IP로 변경하기로 했다. DNS 정리를 완료로 표시하지 않는다. 기존 IP가 재할당될 수 있으므로 복원 전까지 정상 접속 주소로 신뢰하지 않는다.

## 공식 참고

- https://docs.aws.amazon.com/service-authorization/latest/reference/list_ec2.html
- https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceAttribute.html
- https://docs.aws.amazon.com/vpc/latest/userguide/delete-vpc.html

## 후속: 네트워크 인터페이스 화면의 태그 조회

원본 EC2 종료 후 네트워크 인터페이스 화면에 ‘이 리전에는 네트워크 인터페이스가 없음’이 표시됐으나, 상단에 `ec2:DescribeTags`의 identity-based Allow 누락 오류가 함께 나타났다. 최초 6개 목록에서 이 콘솔의 태그 조회 의존성을 놓쳤다. [당시 화면](captures/0239-cleanup-eni-tag-read-warning.png).

보완 권한은 `ec2:DescribeTags` 한 개다. 기존 `B3ReadSeoul.Action`에 추가하고 `Resource: "*"`와 서울 리전 조건을 유지하는 읽기 전용 변경이다. ENI 삭제나 관리자 전체 권한을 추가하는 것은 아니다. 현재 거부된 작업은 DescribeTags이며 DescribeNetworkInterfaces가 거부됐다고 확인한 것은 아니지만, 최종 부재 캡처는 태그 경고 보완 후 새로 고쳐 확인하기로 한다. 후속으로 사용자가 추가 완료를 보고했고, 같은 forB3-1의 서울 ENI 화면에서 DescribeTags 경고가 사라진 상태와 전체 목록에 인터페이스 없음 표시를 확인·캡처했다. [경고 해소 후 확인](captures/0240-cleanup-eni-none-seoul.png). 실제 정책 전체 JSON·기본 버전 번호까지 다시 확인한 것은 아니다. 기존 v4 제안본은 최초 6개 보완안으로 남겨 둔다.

EC2 Terminated·EBS 전체 목록 없음은 별도 단계에서 이미 확인했고 최신 진행은 cleanup-checklist.md에 기록했다. 이 문서의 최초 제안 시점과 현재 원본 종료 상태를 혼동하지 않는다.

## 후속: 서브넷 삭제창의 AWS RAM 조회 누락

서브넷 `subnet-08efa9b32e083838b / b3-1-public-subnet`의 삭제 확인창에서 `ram:GetResourceShareAssociations`가 허용되지 않아 리소스 공유를 로드하지 못하는 오류를 확인했다. 대상 VPC는 `vpc-062ac6fd0606192ab`로 맞고 아직 서브넷 삭제를 실행한 결과가 아니다. [오류 화면](captures/0246-cleanup-subnet-ram-read-warning.png).

AWS RAM은 Resource Access Manager, 즉 자원 공유 관리 서비스다. 공유를 생성한 적이 없어도 콘솔이 공유 여부를 확인할 수 있다. 오류만으로 서브넷이 실제 공유돼 있거나 DeleteSubnet 자체가 거부됐다고 단정하지 않는다.

공식 Service Authorization Reference에서 이 작업은 Read이고 Resource types 칸이 비어 있음을 확인했다. 따라서 특정 resource-share ARN을 넣는 대신 기존 `B3ReadSeoul.Action`에 `ram:GetResourceShareAssociations` 한 개를 추가하고, 기존 `Resource: "*"` 및 서울 리전 조건을 유지하는 보완안을 안내했다. RAM 공유 생성·수정·삭제·초대 권한은 추가하지 않는다. 이 콘솔 의존성은 최초 EC2 조회 목록에서 놓쳤다. 아직 이 보완의 저장·반영은 확인 전이다.

동시에 IAM 버전 화면에서 기본값은 v5, 보존 버전은 v1~v5 총 5개임을 확인했다. 다음 저장 때 버전 한도 안내가 나오면 비기본 과거 버전 처리 내용을 확인해야 하며, 기본 v5나 정책 자체를 임의로 삭제하지 않는다. 이 조회 과정에서 정책·버전을 변경하지 않았다.

공식 근거: https://docs.aws.amazon.com/service-authorization/latest/reference/list_ram.html 및 https://docs.aws.amazon.com/ram/latest/APIReference/API_GetResourceShareAssociations.html

### RAM 안내 정정: 실제 삭제에 필수인 권한으로 단정하지 않는다

사용자가 ‘권한 없어도 삭제되는 것 같다’고 지적했다. 현재 경고는 RAM 공유 정보 조회 거부이고, 기존 `ec2:DeleteSubnet` 권한의 거부가 아니다. 따라서 RAM 권한 추가를 서브넷 삭제의 필수 선행 조건처럼 안내한 점을 정정한다. 실제 삭제 요청이 성공한다면 경고를 없애기 위해서만 RAM 권한을 추가할 필요는 없다. 공유 여부 자체는 이 경고 상태에서 확인하지 못했다는 점을 별도로 기록한다.

재확인 당시 모달은 아직 열려 있고 확인 입력은 ‘삭’ 한 글자이며 삭제 버튼은 비활성이었다. 이는 삭제 완료 증거가 아니다. 사용자가 정확한 확인 문구 ‘삭제’를 완성하고 대상 ID를 확인한 뒤 직접 실행하도록 안내한다. 실제 성공 메시지·새로 고친 목록은 후속 검증 대상으로 남긴다. 이 정정 시점에는 RAM 추가나 서브넷 삭제 성공을 확인하지 않았다.

### 후속: 실습 서브넷 삭제 성공 확인

사용자가 삭제 완료를 보고한 뒤 `subnet-08efa9b32e083838b 삭제 완료` 성공 메시지와, 전체 서브넷 목록에 기본 VPC의 4개만 남고 실습 서브넷이 없는 것을 확인했다. [실제 결과](captures/0247-cleanup-subnet-delete-success-and-absent.png). RAM 조회 오류와 DeleteSubnet 실행 결과는 별개로 기록한다. 삭제 성공은 확인했으나 이 사이의 IAM 정책 전체나 RAM 권한 저장 여부는 새로 검증하지 않았다. RAM 권한 추가를 삭제 필수 조건으로 제시한 최초 안내는 앞선 정정 내용대로 적용하지 않는다.

## 후속: VPC 삭제 전 종속성 검사 차단

실습 SG·Subnet·IGW 정리 후 `b3-1-vpc / vpc-062ac6fd0606192ab`만 선택한 상태에서 VPC 삭제를 시도하자, `ec2:DescribeVpcPeeringConnections` 거부로 ‘종속성을 찾는 동안 오류’가 표시됐다. 같은 화면에 `ec2:DescribeAccountAttributes` 조회 거부도 있었다. 이전 라우팅 화면에서는 `ec2:DescribeVpnGateways` 조회 거부도 직접 관찰했다. 현재 DeleteVpc 실행 성공은 확인하지 않았다. [당시 화면](captures/0254-cleanup-vpc-dependency-read-errors.png).

기존 `B3ReadSeoul.Action`에 다음 읽기 작업을 추가하는 보완안을 안내한다. `Resource: "*"`와 서울 조건을 유지하며 변경·삭제 권한을 넓히지 않는다.

- 직접 거부를 관찰한 항목: `ec2:DescribeVpcPeeringConnections`, `ec2:DescribeAccountAttributes`, `ec2:DescribeVpnGateways`.
- 남은 VPC 의존 자원 점검을 위해 함께 제안하는 항목: `ec2:DescribeEgressOnlyInternetGateways`, `ec2:DescribeTransitGatewayVpcAttachments`. 이 두 항목이 이번 화면에서 실제 거부됐다고 주장하지 않는다.

후자의 두 권한은 송신 전용 IGW·Transit Gateway VPC 연결 유무를 읽는 용도이며, 해당 자원을 만들었거나 반드시 삭제해야 한다는 뜻이 아니다. 실제 자원이 발견되면 실습 범위와 소유·의존성을 따로 검토한다. AWS RAM 조회 경고와 달리 이번에는 콘솔의 VPC 종속성 확인 단계가 실제로 중단된 화면이다. 그래도 이것을 DeleteVpc 자체의 권한 거부로 혼동하지 않는다. 추가 후에는 새로 고쳐 재확인하며, 오류가 앞으로 전혀 없다고 보장하지 않는다. 아직 이번 보완안의 저장·반영은 확인 전이다.

### 후속: VPC 실제 삭제 및 기본 구성 정리 확인

사용자가 삭제 완료를 보고한 뒤, forB3-1 화면에서 `vpc-062ac6fd0606192ab / b3-1-vpc` 삭제 성공 메시지와 기본 VPC 하나만 남은 목록을 확인했다. 이후 라우팅 테이블·네트워크 ACL 화면은 캐시를 갱신해 실습 기본 자원이 없음을 확인했고, 보안 그룹도 기본 VPC 소속 한 개만 남았다. 증빙 0255~0258 및 cleanup-checklist.md에 기록했다. 이 결과는 실제 VPC 삭제 성공 근거이며, 추가 조회 정책 전체 JSON·기본 버전 번호를 다시 검증했다는 뜻은 아니다.
