# 트러블슈팅: Windows SSH 개인키 권한 오류

## 1. 증상

개인키 파일이 존재했지만 SSH에서 `WARNING: UNPROTECTED PRIVATE KEY FILE!`, `Permissions are too open`, `This private key will be ignored`, `Permission denied (publickey,...)`가 발생했습니다.

![키 파일 권한 오류](captures/0148-ssh-private-key-permissions-error.png)

## 2. 원인 가설

서버 연결 전에 Windows OpenSSH가 로컬 개인키의 과도한 접근 권한을 이유로 키 사용을 거부했을 가능성을 확인했습니다. 키가 서버와 불일치한다거나 보안 그룹이 잘못됐다고 먼저 단정하지 않았습니다.

## 3. 검증

- 개인키 파일 존재와 OpenSSH 실행을 확인했습니다.
- 서버 호스트 응답 후 키 읽기 권한 경고가 발생한 순서를 확인했습니다.
- 오류가 인터넷 연결 시간 초과가 아니라 로컬 개인키 사용 거부임을 구분했습니다.

## 4. 실제 조치

개인키 내용을 열거나 재발급하지 않고 **해당 파일 하나의 Windows ACL만** 조정했습니다. 상속된 접근을 정리하고 현재 사용자에게 필요한 읽기 권한을 부여한 뒤 같은 사용자·키·대상으로 SSH를 다시 시도했습니다. Downloads 전체나 서버 SG·IAM을 넓혀 우회하지 않았습니다.

## 5. 결과

Amazon Linux 2023 배너와 `ec2-user` 원격 셸 프롬프트가 표시돼 **SSH 로그인 성공**을 확인했습니다. 이후 같은 서버에서 Nginx와 localhost GET 200도 검증했습니다.

![ACL 수정 후 SSH 성공](captures/0149-ssh-login-success-known-hosts-warning.png)

[후속 localhost GET 200](captures/0202-nginx-localhost-get-200.png)

성공 화면의 `known_hosts` 갱신 권한 경고는 별도 문제입니다. SSH 인증 성공과 구분하며, 이 보고서의 개인키 ACL 해결을 그 경고까지 해결한 것으로 표현하지 않습니다.

## 6. 재발 방지

- 개인키는 Git 밖의 본인 전용 위치에 보관하고 복사·이동 후 ACL을 확인합니다.
- 파일 존재, 키 읽기 권한, 원격 인증, 네트워크 연결을 오류 순서대로 구분합니다.
- Everyone 읽기 권한·SSH 전체 공개·호스트 키 검사 비활성화로 우회하지 않습니다.
