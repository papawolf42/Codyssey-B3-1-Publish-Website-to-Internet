# 실습 리소스 정리 체크리스트

확인일: **2026-10-19**, 서울 `ap-northeast-2`. 아래는 실습 검증 후 **원본 인스턴스와 전용 네트워크**를 정리한 당시 결과입니다. 평가용 복원 등 이후 새로 만든 자원과 구분합니다.

## 필수 다섯 종류

- [x] **EC2 종료**: `i-05d34639a30bbfb6a`의 **Terminated** 확인. 단순 Stop이 아닙니다. [종료 증빙](captures/0237-cleanup-ec2-terminated.png).
- [x] **EBS 삭제 확인**: 루트 `vol-0c465503d65f72630` 및 서울의 추가·미사용 볼륨이 전체 목록에 없음. [전체 볼륨 목록](captures/0238-cleanup-ebs-no-volumes-seoul.png).
- [x] **Elastic IP 해당 없음**: 서울 전체 EIP 목록에 할당 주소가 없어 Release 대상 없음. 자동 할당 퍼블릭 IPv4와 구분했습니다. [EIP 목록](captures/0241-cleanup-eip-none-seoul.png).
- [x] **IGW 분리·삭제**: `igw-0453ef9ebcd131aad` 부재 확인. 다른 IGW는 목록에서 Attached 상태로 남았습니다. 과거 분리 알림만 보지 않고 갱신된 행의 ID·상태를 기준으로 확인했습니다. [실습 IGW 부재](captures/0253-cleanup-igw-absent-default-attached.png).
- [x] **VPC 삭제**: `vpc-062ac6fd0606192ab` 삭제 성공 및 기본 VPC 한 개만 남은 목록 확인. [VPC 삭제 성공](captures/0255-cleanup-vpc-deleted-default-preserved.png).

## 연결 자원

- [x] 실습 SG `sg-0c4336bb1e71eea36` 삭제. [삭제 성공](captures/0244-cleanup-security-group-delete-success.png).
- [x] Subnet `subnet-08efa9b32e083838b` 삭제. [삭제 성공·대상 부재](captures/0247-cleanup-subnet-delete-success-and-absent.png).
- [x] 기본 Route Table `rtb-0f08329ebc84d7fb5`는 VPC 삭제 뒤 목록에서 부재 확인. [구성 당시 대상 테이블](captures/0109-route-save-result.png)과 [삭제 후 남은 테이블 목록](captures/0256-cleanup-main-route-table-absent.png)의 ID를 비교했습니다. 기본 테이블을 먼저 강제 삭제하지 않았습니다.
- [x] NAT Gateway는 서울 전체 목록에 없음. [NAT 목록](captures/0259-cleanup-nat-gateways-none-seoul.png).
- ELB/ALB·RDS는 본 실습 구성에 포함하지 않았습니다.
- [x] 선택 백업 작업의 임시 AMI `ami-080ac9f0097d7ff75`, 연결 스냅샷·S3 객체·버킷도 제거 결과를 확인했습니다. [임시 저장 자원 제거](captures/0233-ami-archive-temp-deleted-original-preserved.png). 로컬 백업·개인키는 삭제하지 않았습니다.

## 정리 순서와 확인 원칙

동작 증빙을 먼저 보관하고 EC2를 종료한 뒤 EBS·EIP·연결 인터페이스를 확인했습니다. 이후 실습 SG·Subnet·IGW를 정리하고 VPC 및 기본 구성 부재를 확인했습니다. 성공 알림과 새로 고친 목록을 근거로 삼고 기본 VPC·다른 프로젝트 자원은 삭제하지 않았습니다.

## 함께 확인한 항목

- [x] 정리 후 Billing을 확인했습니다. [2026-10-19 15:02 KST의 10월 예상 청구서 화면](captures/0261-cleanup-october-estimated-bill-summary.png). 이 캡처는 해당 조회 시점의 표시입니다.
- DNS A 레코드는 향후 복원 서버 IP로 바꾸기 위해 사용자 선택으로 보존했습니다. 이전 IP를 현재 운영 중인 서비스 주소로 신뢰하지 않습니다.
- IAM 사용자·정책·키 페어와 도메인 등록은 별도 보존 대상이며 임의로 삭제하지 않았습니다.
