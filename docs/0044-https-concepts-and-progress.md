# HTTPS 실습 개념 정리와 현재 진행

> **후속 상태:** HTTPS 동작·GET 200·모의 갱신 검증 뒤 EC2와 전용 네트워크는 정리했다. 본문 서버 주소와 Nginx 설정은 검증 당시 설명이다. 자동 갱신은 보장하지 않으며 DNS A 레코드는 사용자 선택으로 남아 있다. [최신 정리 결과](cleanup-checklist.md).

[단계별 계획·전체 작업 기록](0043-https-bonus-step-by-step.md) · [README](../README.md) · [정리 체크리스트](cleanup-checklist.md)

이 문서는 HTTPS 실습 중 질문한 개념을 모은 복습용 문서다. 명령·실패·조치·캡처의 시간순 기록은 위 단계별 문서에 유지한다. 사용자가 직접 조작하고 Aside는 안내·조회·캡처·기록만 수행했다.

## 1. 가비아, Cloudflare, EC2는 각각 무엇을 하나?

- 가비아: 이번 도메인의 구매·갱신을 맡긴 등록기관이다. 도메인을 샀다고 웹 서버가 자동으로 생기는 것은 아니다.
- Cloudflare DNS: 이름을 어떤 IP로 찾을지 알려준다. 이번에는 루트 `kodyssey.kr`의 A 레코드를 사용자가 직접 추가했다.
- EC2: 실제 Nginx 프로그램과 웹 파일이 있는 서버다.
- Nginx: HTTP 요청에 페이지를 보내고, 인증서를 연결한 뒤 HTTPS도 제공한다.

이번 구성은 DNS only다. 따라서 Cloudflare는 DNS 조회를 담당하고, HTTPS 트래픽은 브라우저와 EC2 사이에서 처리된다. Cloudflare를 통과하는 웹 프록시 구성으로 설명하면 안 된다. DNS only는 원본 IP를 공개하며 Cloudflare 웹 프록시 보호를 받지 않는다는 점도 구분한다.

## 2. A 레코드의 @, IP, TTL

`@`는 별도의 하위 이름이 아닌 도메인 자체를 뜻한다. 현재 저장한 설정은 `A / kodyssey.kr / 13.125.99.141 / DNS only / Auto`다.

사용자가 PC에서 `Resolve-DnsName kodyssey.kr -Type A`를 실행해 IP가 일치하는 응답을 확인했다. 이 명령은 DNS를 변경하지 않고 주소를 조회한다. PC에서 실행한 것은 외부 방문자 입장에서 이름을 찾는지 확인하기 위해서였다.

TTL 300은 응답의 캐시 수명 300초를 뜻하며, 반드시 5분 더 기다려야 한다는 뜻은 아니다. PC 한 곳의 성공만으로 전 세계 DNS 캐시가 동시에 갱신됐다고 판단하지 않는다.

## 3. EC2 IP가 바뀌면 DNS도 자동으로 바뀌나?

이번 A 레코드는 IP를 직접 입력한 것이므로 자동으로 따라 바뀌지 않는다. 재부팅과 중지 후 시작, 종료 후 재생성을 구분해야 한다. 자동 할당 공인 IPv4는 중지 후 시작할 때 바뀔 수 있고, 재생성한 서버도 새 IP 확인이 필요하다.

IP가 바뀌면 새 IP를 확인하고 DNS를 직접 수정한다. Elastic IP나 자동 갱신 체계를 별도로 쓸 수 있지만 이번에는 추가하지 않았다. 서버 삭제 후 과거 IP를 계속 가리키면 다른 사람에게 재할당된 서버로 연결될 수 있으므로 DNS도 정리해야 한다.

## 4. Let's Encrypt와 Certbot의 차이

- Let's Encrypt: 무료 TLS 인증서를 발급하는 인증기관(CA).
- Certbot: 도메인 제어를 증명하고 발급·갱신을 요청하는 ACME 클라이언트 프로그램.
- Nginx: 발급된 인증서와 개인키를 사용해 실제 TLS 통신을 제공하는 웹 서버.

이번에는 Certbot으로 Let's Encrypt 인증서를 받았다. `certonly --webroot`를 사용했으므로 Certbot이 Nginx TLS 설정까지 자동 완성한 것은 아니다. 발급 후 사용자가 별도 설정 파일을 만들고 적용했다.

## 5. 어떻게 무료로 운영할 수 있나?

Let's Encrypt는 비영리 ISRG의 프로젝트이며 기업·단체 후원과 개인 기부로 운영한다. 기부는 선택이고 인증서마다 이용료를 받지 않는다.

ACME로 도메인 제어 확인과 발급·갱신을 자동화해 수작업을 줄인다. 제공하는 인증서는 도메인 검증(DV) 유형이며, 회사 실체를 확인하는 OV/EV 인증서와 범위가 다르다. DV는 사이트 사업이나 콘텐츠가 안전하다는 보증이 아니다.

인증서가 무료라고 암호화가 약한 것은 아니다. 실제 보안은 서버 설정·개인키 보호·인증서 검증·갱신에도 달려 있다. 인증서 발급과 달리 EC2·EBS·공인 IPv4·트래픽·도메인 갱신 비용은 별도다. Let's Encrypt가 웹사이트를 호스팅하거나 모든 방문자 트래픽을 중계하는 것은 아니다.

## 6. DNF와 Python을 왜 확인했나?

DNF는 Amazon Linux 2023의 패키지 관리 도구로 저장소에서 프로그램을 설치하고 의존성을 해결한다. RPM은 패키지 형식과 저수준 관리 체계이며, DNF는 그 위에서 저장소·의존성을 다룬다.

Certbot이 Python으로 동작하므로 환경을 확인했다. 실제 기본 Python은 3.9.25였다. 최신 pip 패키지를 무조건 설치하지 않고 AL2023 저장소의 Certbot을 선택했으며, 실제 설치·실행 확인 버전은 2.6.0이다. 시스템 Python의 연결을 다른 버전으로 바꾸지 않았다.

## 7. webroot와 Permission denied

Nginx의 `root /usr/share/nginx/html;`은 웹 파일을 찾는 폴더 설정이다. `#`로 시작하는 줄은 주석이므로 적용되지 않는다.

일반 계정으로 이 시스템 폴더 아래에 디렉터리를 만들 때 Permission denied가 발생했다. 필요한 폴더 생성과 테스트 파일 쓰기 명령에만 sudo를 사용했고, 폴더 전체에 777 권한을 주거나 소유권을 바꾸는 식으로 우회하지 않았다.

`/.well-known/acme-challenge/b3-1-check.txt`의 `kodyssey-acme-test`가 외부 HTTP로 보이는지 사전 시험했다. 실제 발급 때는 Certbot이 별도의 검증 토큰 파일을 준비하고 인증기관이 그것을 확인한다. 직접 만든 테스트 문구 파일 자체가 실제 발급용 인증 토큰은 아니다.

## 8. fullchain.pem과 privkey.pem

- `fullchain.pem`: 서버 인증서와 필요한 중간 인증서 체인.
- `privkey.pem`: 그 인증서의 공개키에 대응하는 서버 개인키.

Nginx에는 두 파일의 경로를 지정한다. 개인키 내용을 화면·채팅·캡처·Git에 넣지 않는다. 인증서의 발급 성공과 웹 서버에서 그 인증서를 사용하는 것은 서로 다른 단계다.

이번 발급은 `kodyssey.kr` 대상이며 화면상 만료일은 2027-01-17이다. 공개 인증서의 도메인 이름은 CT 기록에 남을 수 있고, DNS 삭제가 이 이력까지 지우지는 않는다.

## 9. nginx.conf를 직접 수정하지 않은 이유

주 설정에서 `include /etc/nginx/conf.d/*.conf;`를 확인했다. 이 지시문이 별도 `.conf` 파일도 읽게 한다.

기존 conf.d 목록이 비어 있는 상태에서 사용자가 `kodyssey-https.conf`를 새로 작성했다. 기존 HTTP 80 설정은 유지하고, 새 파일에 HTTPS 443과 `server_name kodyssey.kr`, 웹 루트, 인증서 경로, TLS 1.2/1.3을 넣었다. 기존 파일을 덮어쓰지 않고 기능별로 분리한 것이다.

## 10. 포트 허용, 문법 검사, reload, 접속 검증

- SG 443 허용: 네트워크 접속을 허용하는 단계. 이것만으로 HTTPS가 생기지 않는다.
- `nginx -t`: 문법과 참조 파일 접근을 검사한다. 실행 중 서비스에 새 설정을 적용하는 명령은 아니다.
- `systemctl reload nginx`: 검사한 설정을 실행 중 Nginx에 다시 읽히게 한다. 일반적으로 연결 영향을 줄이는 방식이지만 오류가 없는지 확인해야 한다.
- 브라우저 HTTPS 접속: 실제 외부 경로에서 페이지가 열리는지 확인한다.
- `curl -i https://kodyssey.kr/`: 인증서 검증을 우회하지 않은 GET 응답 코드·본문을 확인할 후속 시험이다. `-k`로 우회하면 정상 인증서 증거로 사용할 수 없다.

## 11. 현재 완료한 것

- 사용자 PC DNS A 응답 확인, 루트 도메인 HTTP 표시.
- HTTP 80·HTTPS 443 공개, SSH 22 개인 IP /32 제한인 SG 저장.
- Certbot 설치·실행, webroot 사전 검증, 인증서 발급.
- 별도 Nginx HTTPS 설정 작성 및 include·문법 검사 성공.
- 터미널 화면에서 사용자가 실행한 reload 명령이 오류 없이 프롬프트로 돌아온 것을 확인.
- 열린 `https://kodyssey.kr/` 탭에서 오류 안내 페이지가 아닌 Nginx 환영 페이지를 확인·캡처.
- EC2 SSH의 `curl -i https://kodyssey.kr/`에서 `HTTP/1.1 200 OK`와 HTML 본문 확인·캡처. 명령에 `-k` 없음. 이는 PC PowerShell 실행 결과가 아니다.

즉, HTTPS 보너스의 핵심인 도메인 연결·인증서 적용·브라우저 표시까지 확인했다. 캡처는 본문 영역이며 URL은 실제 탭의 snapshot으로 확인했다. 별도의 인증서 상세 창까지 확인한 것으로 주장하지 않는다.

## 12. 아직 남은 확인과 마무리

- HTTPS GET 200은 EC2에서 확인 완료했다. 외부 PC PowerShell의 curl 응답 코드는 별도로 확인하지 않았으며, 외부 접속 증거는 브라우저 HTTPS 페이지 표시로 구분한다.
- 실제 timer는 마지막 확인에서 `disabled`·`inactive (dead)`였다. `certbot renew --dry-run`은 성공했다. 사용자는 명세의 필수가 아닌 timer 활성화와 갱신 후 Nginx reload hook 추가를 생략하기로 했다. 활성화·hook 작성 명령은 실행하지 않았다. 자동 갱신이 작동한다고 주장하지 않으며, 서비스를 계속 운영하려면 만료 전 갱신 대책을 별도로 마련해야 한다.
- webroot 방식의 갱신 후 Nginx reload 처리 확인.
- 기존 IP의 HTTP·localhost 동작 유지 확인과 실제 HTTPS 흐름을 반영한 다이어그램 갱신.
- 필요하면 인증서 상세의 이름·발급자·유효 기간 캡처.
- Docker 보너스는 별도로 결정하며 HTTPS 작업으로 완료 처리하지 않는다.
- 선택 실습 종료 후 실습 DNS와 AWS 자원 정리·결과 증빙. HTTPS 성공이 과제 전체 완료나 비용 무료 보증은 아니다.

## 공식 자료

- https://letsencrypt.org/docs/faq/
- https://letsencrypt.org/how-it-works/
- https://letsencrypt.org/sponsors/
- https://docs.aws.amazon.com/linux/al2023/ug/python.html
- https://docs.aws.amazon.com/linux/al2023/release-notes/relnotes-2023.3.20231211.html
- https://developers.cloudflare.com/dns/proxy-status/

작성일: 2026-10-19. 최신 실제 작업 증거는 단계별 진행 기록을 함께 확인한다.
