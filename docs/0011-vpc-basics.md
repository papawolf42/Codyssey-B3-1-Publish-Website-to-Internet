# 0011. VPC 기초: AWS 안의 네트워크 공간

## 오늘의 한 가지 개념

**VPC = Virtual Private Cloud**다. AWS 안에서 내가 사용할 수 있도록 따로 잡아 두는, 주소 범위가 있는 가상 네트워크 공간이다.

서버가 실제로 어느 네트워크 안에 놓일지 정하는 바탕이라고 생각하면 된다. 이 과제에서는 서울 리전에 VPC 하나를 만들고, 그 안에 Subnet과 EC2 서버를 배치한다.

## VPC가 하는 일

- AWS 안에서 실습용 네트워크의 경계를 정한다.
- 그 네트워크가 사용할 IP 주소 범위를 정한다.
- Subnet, Route Table, Internet Gateway 같은 네트워크 요소를 그 경계에 연결한다.

## VPC가 아닌 것

- 웹사이트나 웹 서버가 아니다.
- EC2 가상 서버 자체가 아니다.
- VPC를 만들었다고 해서 인터넷에서 자동으로 접속할 수 있는 것은 아니다.

외부 인터넷 요청이 EC2까지 오려면 이후에 Subnet, 경로, Internet Gateway, 퍼블릭 IP, 보안 규칙 등이 서로 맞아야 한다. 이 구성요소들은 각각 배우는 단계에서 설명한다.

## 지금은 AWS에서 만들지 않는다

아직은 개념을 익히는 단계다. 실제 VPC를 만들기 전에는 IP 주소 범위, 리전, 비용·정리 계획을 함께 확인하고, 생성할 구성을 먼저 보여준 뒤 승인을 받는다.

## 이해 확인

VPC는 웹 서버 자체일까, 아니면 AWS 자원을 담아 둘 네트워크 공간일까? 또 VPC만 만든 것으로 외부 인터넷 접속이 자동으로 열릴까?


## 꼬리 질문: Subnet과 EC2

### Subnet은?

**Subnet(서브넷)**은 VPC의 IP 주소 범위를 더 작은 구역으로 나눈 것이다. EC2 서버는 VPC에 바로 떠 있는 것이 아니라, 한 Subnet 안에 배치된다. 각 Subnet은 하나의 Availability Zone(가용 영역)에 속하지만, 지금은 “서울 리전 안의 한 데이터센터 구역” 정도로 이해하면 충분하다.

Subnet에 “public”이라는 이름을 붙이는 것만으로 인터넷이 연결되는 것은 아니다. AWS에서는 해당 Subnet이 연결된 Route Table에 Internet Gateway를 향하는 인터넷 경로가 있을 때 Public Subnet이라고 부른다. 인스턴스에도 인터넷 통신을 위한 public IP가 있어야 한다.

### EC2는?

**EC2 = Elastic Compute Cloud**다. AWS에서 빌려 쓰는 가상 서버다. 이 과제에서는 EC2에 Linux와 Nginx를 설치하고 `Hello Cloud` 페이지를 제공한다.

EC2는 Subnet 안에서 VPC의 private IP를 받는다. 외부에서 직접 접속시키려면 여기에 public IPv4 주소도 필요하다. 두 주소는 역할이 다르며, 나중에 콘솔에서 실제 값을 함께 확인한다.

## 꼬리 질문: VPC 주소는 사설 IP와 비슷한가?

대체로 맞는 방향이다. VPC는 단일 IP 주소가 아니라 **IP 주소 범위(CIDR)**를 가진 네트워크다. 학습용 VPC에는 흔히 사설 IPv4 범위를 사용한다. 사설 범위는 인터넷에서 전 세계적으로 직접 라우팅되는 공인 IP 범위와 다르다.

표준 사설 IPv4 범위는 다음 세 가지다.

- `10.0.0.0`부터 `10.255.255.255`까지 (`10.0.0.0/8`)
- `172.16.0.0`부터 `172.31.255.255`까지 (`172.16.0.0/12`)
- `192.168.0.0`부터 `192.168.255.255`까지 (`192.168.0.0/16`)

따라서 `162`가 아니라 아마 `172.16`~`172.31`을 떠올린 것일 수 있다. `172`로 시작한다고 전부 사설은 아니고 위의 범위만 해당한다. `100`도 전체가 사설 범위는 아니다. 특히 `100.64.0.0/10`은 통신사업자용 공유 주소 공간으로, RFC 1918 사설 범위와는 다른 용도다.

이번 과제에서는 VPC의 사설 범위를 예를 들어 `10.0.0.0/16`처럼 정하고, EC2에는 별도로 public IPv4를 붙여 외부 접속을 제공할 수 있다. 즉, **VPC의 사설 IP 범위와 EC2의 public IP는 함께 쓰일 수 있다.**

## 꼬리 질문: 외부 접속에 포트포워딩이 필요한가?

질문의 핵심은 맞다. 외부 요청이 서버까지 도달하도록 네트워크 경로를 구성해야 한다. 다만 집 공유기 설정 화면에서 하는 전통적인 “포트포워딩 규칙”을 AWS에서 그대로 만드는 것은 아니다.

이 과제에서 HTTP 요청이 들어오는 길은 다음 요소가 함께 만든다.

1. 브라우저가 EC2의 public IPv4 주소로 요청한다.
2. VPC에 붙은 Internet Gateway가 public IPv4와 EC2의 private IPv4 사이 주소 변환을 처리한다.
3. Public Subnet의 Route Table이 인터넷 방향 경로(`0.0.0.0/0 → Internet Gateway`)를 제공한다.
4. Security Group이 HTTP 포트 80의 인바운드 요청을 허용한다.
5. EC2에서 Nginx가 포트 80을 실제로 듣고 응답한다.

그래서 “포트포워딩 하나만 설정하면 끝”은 아니다. public IP, 경로, 포트 허용, 서버 프로그램이 모두 맞아야 한다. Internet Gateway는 포트별 방화벽이 아니며, Security Group은 인터넷으로 가는 경로를 만드는 장치가 아니다. 각 구성요소의 자세한 설명은 해당 단계를 시작할 때 하나씩 다룬다.

## 참고 자료

- [AWS: What is Amazon VPC?](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [AWS: IP addressing for your VPCs and subnets](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html)
- [AWS: Enable internet access for a VPC using an internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)
- [RFC 1918: Address Allocation for Private Internets](https://datatracker.ietf.org/doc/html/rfc1918)
- [RFC 6598: Shared Address Space](https://datatracker.ietf.org/doc/html/rfc6598)
