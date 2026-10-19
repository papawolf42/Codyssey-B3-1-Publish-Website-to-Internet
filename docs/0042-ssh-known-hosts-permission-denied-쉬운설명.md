# SSH는 접속됐는데 known_hosts Permission denied가 뜨는 이유

[기존 오류 기록: TS-006](troubleshooting.md#ts-006-ssh는-성공했으나-windows-known_hosts-갱신-권한-경고) · [SSH와 GET 성공 화면](captures/0202-nginx-localhost-get-200.png)

## 1. 한 줄 결론

**내 PC의 SSH 프로그램이 서버 신원 기록을 갱신하려다가, Windows의 로컬 파일 접근 권한 때문에 임시 파일을 만들지 못한 경고다.** EC2 접속 인증 실패와는 다른 문제다.

현재 상태는 **SSH 접속·GET 응답 성공 / known_hosts 갱신 문제 미해결 / 구체적인 Windows ACL 원인 미확인**이다. 이번에 파일·폴더 권한을 변경하거나 파일을 삭제하지 않았다.

## 2. 메시지 해석

```text
hostfile_replace_entries: mkstemp: Permission denied
update_known_hosts: hostfile_replace_entries failed for C:\Users\alsgu/.ssh/known_hosts: Permission denied
```

- `hostfile_replace_entries`: 저장된 서버 호스트 키 항목을 교체·갱신하는 처리.
- `mkstemp`: 안전한 임시 파일을 만드는 처리.
- `Permission denied`: 운영체제가 파일 작업을 거부했다는 뜻.
- `update_known_hosts`: 서버의 호스트 키 기록 갱신이 실패했다는 후속 메시지.
- `C:\Users\alsgu/.ssh/known_hosts`: EC2 안이 아니라 **내 Windows PC에 있는 경로**다.

오류 경로에 `/`와 `\`가 섞였다는 사실만으로 경로 표기 오류라고 판단하지 않는다.

## 3. known_hosts는 어떤 파일인가?

SSH에는 양방향 신원 확인이 있다.

1. **서버가 사용자를 확인:** 내가 가진 개인키로 접속할 자격을 증명한다.
2. **사용자가 서버를 확인:** 접속한 서버의 호스트 키로 서버 신원을 확인한다.

`Downloads`의 `b3-1-key.pem`은 첫 번째에 사용하는 **내 개인키**다. `known_hosts`는 두 번째에 사용하는 **알고 있는 서버의 공개 호스트 키 기록**이다. 비밀번호나 내 개인키를 저장하는 파일이 아니다.

비유하면 개인키는 '내 출입증', known_hosts는 '내가 알고 있는 건물의 신원 기록'이다. 둘은 역할도 파일도 다르다.

서버 신원 정보를 대조하는 데 도움이 되는 파일이지만, 저장된 항목이 있다는 것만으로 최초 접속 때 서버 신원을 별도 신뢰 경로로 검증했다는 뜻은 아니다.

## 4. 왜 단순 저장이 아니라 임시 파일을 만들까?

OpenSSH의 공개 `hostfile.c` 구현을 확인하면 다음 순서가 있다.

1. 원본 경로 뒤에 임의 문자를 붙인 임시 파일 이름을 만든다. 예를 들면 `.ssh/known_hosts.XXXXXXXXXXX` 형태다.
2. `mkstemp`로 **같은 폴더에 임시 파일을 생성**한다.
3. 갱신한 내용을 준비한다.
4. 변경 사항이 있으면 기존 파일을 백업하고 새 파일로 교체한다.

중간에 오류가 나더라도 원본을 직접 덮어쓰다 망가뜨릴 위험을 줄이는 방식이다.

이번 메시지는 이 중 **임시 파일 생성 단계가 거부됐다**는 것을 보여준다. 따라서 known_hosts 파일의 쓰기 권한뿐 아니라 **부모 `.ssh` 폴더에서 파일을 생성할 권한**이 중요하다. 기존 파일을 읽거나 일부 내용을 추가할 수 있어도, 같은 폴더에 새 파일을 만들거나 파일을 교체하는 작업은 별도로 실패할 수 있다.

이는 공개 공통 구현으로 확인한 원리다. 설치된 Windows OpenSSH 버전의 전체 구현을 별도로 대조하거나 실제 ACL을 분석한 것은 아니다.

## 5. 접속했는데도 왜 갱신하려고 하나?

OpenSSH에는 서버가 알리는 추가 호스트 키를 학습하는 `UpdateHostKeys` 기능이 있다. 서버는 여러 종류의 호스트 키를 사용할 수 있으며, 이미 확인한 키로 연결한 뒤 다른 키 정보를 갱신하는 경우가 있다.

따라서 **현재 연결에 필요한 신원 확인·사용자 인증은 진행됐지만, 이후 호스트 키 파일 갱신만 실패**하는 상황이 가능하다. 이번 오류가 어떤 키의 추가·정리 때문에 발생했는지는 상세 로그로 분석하지 않았으므로 특정 키 교체가 있었다고 단정하지 않는다.

## 6. 이번 실습에서 확인된 것과 아직 모르는 것

### 확인된 것

- 과거에도 같은 known_hosts 갱신 경고와 함께 `.ssh` 디렉터리 접근 거부가 기록됐다.
- 이번 화면에는 `ec2-user@ip-10-0-1-200` 원격 셸이 열렸다.
- 사용자가 그 셸에서 `curl -i http://localhost`를 실행해 `HTTP/1.1 200 OK`와 Nginx HTML을 받았다.
- 따라서 이번 경고만으로 SSH 인증 실패나 Nginx 배포 실패라고 판정할 수 없다.

### 아직 확인하지 않은 것

- `.ssh`와 `known_hosts`의 실제 소유자 및 Windows ACL.
- SSH를 실행한 현재 Windows 사용자에게 어떤 허용·거부 규칙이 적용되는지.
- 읽기 전용 속성이나 보안 프로그램 등의 추가 차단 여부.

**우선 의심할 것은 로컬 `.ssh` 폴더의 접근·파일 생성 권한이다.** 다만 어떤 ACL 항목이 직접 원인인지는 아직 확정하지 않았다. 사용자 이름 변경, 권한 상속, 다른 계정으로 생성된 폴더 등도 실제 상태를 보기 전에는 추측이다.

## 7. 예전 개인키 권한 오류와 어떻게 다른가?

예전의 `UNPROTECTED PRIVATE KEY FILE` / `Permissions are too open`은 개인키를 다른 사람이 읽을 수 있어 OpenSSH가 개인키 사용을 거부한 문제였다. 해당 개인키의 ACL을 조정한 뒤 SSH 로그인에 성공했다.

지금은 **known_hosts 갱신에 필요한 로컬 파일 작업이 거부되는 문제**다. 개인키 파일 권한을 더 조이거나 키 페어를 새로 만드는 조치가 직접적인 해결책인 것은 아니다. 이전 개인키 ACL 조정이 이 경고의 원인이었다는 근거도 없다.

## 8. 나중에 확인한다면: 권한을 바꾸지 않는 조회부터

지금 연결된 EC2 셸이 아니라, **내 PC의 별도 일반 PowerShell**에서 확인한다. 열린 SSH를 굳이 끊지 않아도 된다.

먼저 실행 사용자와 프로필 경로를 확인한다.

```powershell
whoami
$env:USERPROFILE
```

오류에 나온 경로가 현재 프로필과 같은지 확인한 뒤 폴더와 파일의 ACL을 각각 조회한다.

```powershell
Get-Acl "$env:USERPROFILE\.ssh" | Format-List Owner, AccessToString
Get-Acl "$env:USERPROFILE\.ssh\known_hosts" | Format-List Owner, AccessToString
```

이 명령은 ACL을 읽을 뿐 변경하지 않으며 개인키 내용도 열지 않는다. 조회 자체가 접근 거부되면 그 결과도 진단 근거다. 위 명령은 이번 문서 작성 과정에서 대신 실행하지 않았다.

실제 결과를 보고 현재 사용자에게 필요한 범위의 폴더·파일 접근을 복구하는 방안을 정한다. 권한을 바꿔야 한다면 대상과 변경 내용을 먼저 확인하고 사용자가 직접 적용한 뒤 재접속 결과로 검증한다. 폴더 전체에 일괄 권한 변경 명령을 먼저 적용하지 않는다.

## 9. 하지 않을 조치

- 경고를 없애려고 `StrictHostKeyChecking`을 비활성화하지 않는다.
- known_hosts 전체나 `.ssh` 폴더를 무작정 삭제하지 않는다.
- `Everyone`에게 전체 제어를 주지 않는다.
- EC2의 Security Group·IAM·Nginx를 바꿔 로컬 Windows 파일 권한을 해결하려 하지 않는다.
- EC2에서 `sudo`를 실행해 내 PC의 파일 권한을 고치려 하지 않는다.
- 관리자 권한 터미널에서만 실행하는 것을 근본 해결로 취급하지 않는다.

이 경고는 `REMOTE HOST IDENTIFICATION HAS CHANGED`나 `Host key verification failed`와도 구분한다. 나중에 그런 경고가 나오면 지금 문제와 같다고 넘기지 말고, 서버가 재생성되었는지·IP가 재사용되었는지 등을 확인하고 신뢰할 수 있는 경로로 지문을 대조한다.

## 10. 지금 과제에서의 의미

현재 SSH와 HTTP GET 성공 증빙은 유효하다. 이 로컬 경고가 있다는 이유만으로 EC2를 다시 만들거나 배포를 실패로 처리할 필요는 없다. 다만 서버 신원 기록을 정상적으로 유지하지 못하는 상태이므로, 영구적으로 무시하거나 해결 완료로 기록해서는 안 된다. 과제의 리소스 정리와는 별개의 로컬 보완 항목이다.

## 근거

- 관찰 기록: [troubleshooting.md TS-006](troubleshooting.md#ts-006-ssh는-성공했으나-windows-known_hosts-갱신-권한-경고).
- 최신 관찰: [SSH 셸 및 GET 200 캡처](captures/0202-nginx-localhost-get-200.png).
- OpenSSH 공개 소스 `hostfile_replace_entries`: https://github.com/openssh/openssh-portable/blob/master/hostfile.c
- OpenSSH `ssh_config` 설명서의 `UpdateHostKeys`, `UserKnownHostsFile`: https://man7.org/linux/man-pages/man5/ssh_config.5.html

문서 작성일: 2026-10-19. 권한 수정·파일 삭제·SSH 설정 변경은 수행하지 않았다.
