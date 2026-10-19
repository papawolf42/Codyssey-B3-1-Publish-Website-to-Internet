# AMI 로컬 백업 실제 작업 기록

> **백업 작업 이후의 후속 상태:** 사용자가 별도 승인·직접 실행으로 원본 EC2와 실습 네트워크를 정리했고 루트 EBS 부재도 확인했다. 아래 백업 단계의 ‘원본 보존’은 당시 범위다. 로컬 암호화 백업·복구키는 보존하며 AWS 재업로드·새 EC2 부팅 시험은 하지 않았다. [원본 자원 정리 결과](cleanup-checklist.md).

[나중에 복원할 때 보는 참고 문서](0048-local-ami-backup-restore-guide.md) · [방법 설명](0046-ami-local-archive-선택지.md) · [정리 체크리스트](cleanup-checklist.md)

## 범위와 승인

- 사용자는 AMI를 다운로드해 직접 보관하고 나중에 업로드해 복원하는 방식을 선택했다.
- 이 백업은 과제 필수 단계가 아닌 추가 작업이며, 사용자가 assistant의 자동 진행과 주요 단계 캡처를 요청했다.
- 기존의 사용자 직접 AWS 조작 원칙에 대한 예외는 **이 백업 작업에 한정**한다. 기존 실습 자원 삭제나 제출 자료 변경을 포괄적으로 승인한 것은 아니다.
- 원본 EC2·EBS·네트워크는 삭제하지 않는다. 재부팅이 필요하면 먼저 확인한다.
- 개인키·인증 정보·서명된 다운로드 URL은 채팅·문서·캡처·Git에 기록하지 않는다.

## 2026-10-19 사전 확인

### 실제 조회한 상태

AWS 콘솔의 기존 `AccountFullAccessRole` 관리 세션에서 서울 리전 CloudShell을 열고, CLI의 STS 신원과 대상 리소스를 조회했다. 새 IAM 권한이나 장기 액세스 키를 발급하지 않았다. 과제용 `B3Ec2SeoulLabPolicy`는 수정하지 않았다.

- 계정: `067518846638`
- 리전: `ap-northeast-2`
- 원본 EC2: `i-05d34639a30bbfb6a`, 조회 당시 `running`
- 공인 IP: `13.125.99.141`
- 아키텍처: `x86_64`
- 가상화: `hvm`
- 루트 유형: `ebs`
- 연결 볼륨: `vol-0c465503d65f72630`
- 볼륨: 8 GiB, `in-use`, `ap-northeast-2a`, 암호화 `false`
- 해당 리전 EBS 기본 암호화: `false`

EBS/HVM이라는 기본 보관 지원 조건을 충족한다. 실제 보관 대상은 아직 생성하지 않은 자기 계정 소유의 비공개 AMI다. AMI·스냅샷 완료, Store API의 성공과 다운로드·무결성·복원 가능성까지 검증한 것은 아니다.

[사전 확인 캡처](captures/0221-ami-local-archive-preflight.png)

### 로컬 준비 상태

C 드라이브 여유 공간은 조회 시 약 532 GiB로, 8 GiB 볼륨의 보관 파일을 다루는 데 충분하다. 최종 압축 파일 크기는 생성 후 확인한다. PATH에서 `age`·`7z`·`gpg`·`openssl`은 확인되지 않았다. Aside Vault도 미설정 상태였으며, 새로 설정하거나 비밀 값을 조회하지 않았다.

사용자가 잠깐의 재부팅을 허용했고, Git 밖 전용 폴더 `C:\Users\alsgu\.aside\u\0\backups\B3-1` 사용을 승인했다. 실제 작업 하위 폴더는 `20261019-01`이다. 이 새 폴더는 ACL 상속을 끊고 현재 사용자와 SYSTEM에만 FullControl을 허용했다. C 드라이브 다른 폴더의 ACL은 변경하지 않았다.

공식 age v1.3.2 Windows amd64 ZIP을 받아 공식 배포 digest와 SHA-256이 일치함을 확인했다. 로컬 도구의 `--version`도 `v1.3.2`로 확인했다. 설치 프로그램을 시스템에 설치하거나 PATH를 변경한 것은 아니며 작업 폴더의 portable 실행 파일만 사용한다.

복구키는 `recovery\b3-1-archive.agekey` 파일에만 생성했고 내용은 출력하지 않았다. 공개 recipient 파일은 `recipient.txt`다. 이미지 암호화·복호화 및 해시 확인은 다운로드 후 수행할 예정이며, 키 생성 자체가 이미지 백업 성공을 뜻하지 않는다. 복구키를 잃으면 암호화된 백업을 복호화할 수 없으므로 별도 안전 보관이 필요하다.

## 진행 체크리스트

- [x] 재부팅 여부·보관 위치 결정.
- [x] 원본 EC2의 비공개 AMI 생성과 완료 확인.
- [x] 공개 차단·암호화가 적용된 임시 S3 버킷 준비.
- [x] AMI Store 작업과 완료 확인.
- [x] 로컬 다운로드·해시·암호화·복호화·보호 설정 확인.
- [x] 검증 범위와 미실행한 AWS 재업로드/부팅 시험을 구분해 복원 방법 기록.
- [x] 백업용 임시 AWS 자원 정리 승인 및 실제 삭제 결과 기록.

### 실제 AMI 생성 요청과 원본 복구

- 이름: `b3-1-local-backup-20261019-01`
- 새 AMI ID: `ami-080ac9f0097d7ff75`
- 기본 재부팅 방식으로 CreateImage를 1회 요청했다. `--no-reboot`를 사용하지 않았다.
- API 조회 당시 AMI는 `pending`, 소유 계정은 `067518846638`, `Public=false`였다. 아직 `available` 확인 전이며 이 시점에는 SnapshotId도 조회 결과에 없었다.
- 원본 EC2의 후속 상태 조회: `running`, 인스턴스 검사 `ok`, 시스템 검사 `ok`.
- CloudShell에서 TLS 검증을 유지한 외부 HTTPS GET 결과: `HTTPS_STATUS=200`.
- 원본 인스턴스·EBS·네트워크의 종료·삭제는 하지 않았다.

증빙: [생성 요청](captures/0222-ami-local-archive-created.png), [AMI pending](captures/0223-ami-local-archive-pending.png), [재부팅 후 HTTPS 복구](captures/0224-ami-reboot-https-restored.png).

### AMI 완료 및 S3 보관 완료

후속 조회에서 AMI는 `available`, `Public=false`, 루트 스냅샷은 `snap-072f6fd207837a843`, 크기는 8 GiB로 확인했다.

임시 S3: `b3-1-ami-archive-067518846638-20261019-080ac9f`. 생성 후 공개 차단 네 항목 `true`, SSE-S3 `AES256`, `BucketOwnerEnforced`, `IsPublic=false`를 조회 확인했다. 비 TLS 요청을 거부하는 정책도 저장했다. 과제 IAM 정책을 확장하지 않았다.

`CreateStoreImageTask` 1회 요청으로 객체 키 `ami-080ac9f0097d7ff75.bin`을 받았다. 이후 `DescribeStoreImageTasks`에서 `Completed`, 진행률 100%, 실패 사유 빈 문자열로 확인했다.

- Store 작업 시작: `2026-10-19T04:55:52.297000+00:00`.
- S3 객체 크기: `603450438` bytes, 약 575.5 MiB.
- 객체 암호화: `AES256`.
- S3 객체를 CloudShell에서 스트리밍해 계산한 SHA-256: `7c9c9618f466f7fd7e30007db617ac6dd56df3cd771a28e75a10e0af16e7ea49`.
- ETag는 multipart 형식이므로 파일 전체의 MD5라고 해석하지 않는다.

증빙: [S3 보호 설정](captures/0225-ami-archive-s3-private-encrypted.png), [AMI available](captures/0226-ami-local-archive-available.png), [Store 요청](captures/0227-ami-store-task-created.png), [Store 완료](captures/0228-ami-store-task-completed.png), [객체 크기·원본 SHA-256](captures/0229-ami-archive-size-and-source-sha256.png).

### 로컬 전송 진행

CloudShell 파일 다운로드 경로를 비밀 정보 없는 작은 파일로 먼저 시험했다. 임시 서명 URL은 보호된 파일과 비공개 메모리로만 전달했고 내용은 출력·캡처하지 않았다. 브라우저의 임시 다운로드 사본과 세션 임시 URL 파일도 삭제했다.

첫 REPL 스트림 전송은 실행 수명 종료로 중단됐고, 로컬 임시 파일은 0바이트였다. 이 0바이트 파일만 제거하고 별도 PowerShell 스트리밍 방식으로 재시도했다. 응답 HTTP 200·Content-Length·ETag·전체 바이트 수와 S3 원본 SHA-256을 모두 확인했으며, 재시도는 종료 코드 0과 `DOWNLOAD_VERIFIED`로 완료했다.

- 다운로드 크기: `603450438` bytes.
- 로컬 원본 SHA-256: S3 원본의 `7c9c9618f466f7fd7e30007db617ac6dd56df3cd771a28e75a10e0af16e7ea49`와 일치.
- 최종 암호화 파일: `C:\Users\alsgu\.aside\u\0\backups\B3-1\20261019-01\ami-080ac9f0097d7ff75.bin.age`.
- 암호화 파일 크기: `603597950` bytes.
- 암호화 파일 SHA-256: `186bb6595857d87b51223b903d0ec5ed1dbb1a6075daf0e5142ecdc5c1cf8e3f`.
- 복구키: 같은 작업 폴더의 `recovery\b3-1-archive.agekey`. 파일 내용은 출력·문서화하지 않았다.
- 로컬 `Restore-LocalArchive.ps1` 도우미로 암호화 파일을 실제 복호화했고 크기 및 원본 SHA-256 일치, 종료 코드 0과 `RESTORE_VERIFIED`를 확인했다.
- 검증한 평문 이미지 임시 사본 2개와 시험·전송 임시 파일만 정리했다. 이는 SSD 등의 복구 불가능한 보안 삭제를 보장한다는 뜻은 아니다.
- CloudShell의 임시 URL 파일도 삭제했다. 임시 서명 주소·인증 정보는 문서·캡처에 기록하지 않았다.

보관 폴더에는 `manifest.json`, `verification.txt`, `README-복원방법.md`, 복원 도우미와 portable 도구를 함께 뒀다. `.age`를 그대로 AMI Restore API에 올리는 것이 아니라 도우미로 검증·복호화한 `.bin`만 비공개 S3에 업로드한다. 복구키를 S3에 업로드해서는 안 된다.

완료 직전 AWS 재조회에서 원본 EC2는 `running`, 공인 IP는 `13.125.99.141`였고 외부 HTTPS GET은 200이었다. S3 객체도 여전히 존재했다. [원본 유지 최종 확인](captures/0230-ami-backup-original-still-running.png).

브라우저의 로컬 파일 접근이 허용되지 않아 `verification.txt` 파일 화면 캡처는 하지 못했다. 이를 우회하거나 브라우저 권한을 확장하지 않았다. 로컬 단계의 실제 명령 결과와 검증 보고서를 기록했고, AWS 단계의 화면 캡처는 정리까지 포함해 0221–0233 총 13장 보관했다.

### 사용자 승인 후 임시 백업 AWS 자원 정리 완료

사용자는 추가 확인 질문에서 ‘삭제하죠’라고 승인했다. 삭제 범위는 이번 작업에서 만든 AMI·스냅샷·S3 객체·버킷으로 한정했고, 원본 EC2·EBS·네트워크와 로컬 백업·복구키는 제외했다.

삭제 전 AMI의 이름·소유 계정·루트 스냅샷, 스냅샷의 소유 계정·원본 볼륨·CreateImage 설명, 작업 전용 버킷 태그·버전 관리·미완료 업로드를 조회해 대상을 확인했다. AMI 등록 해제 후 연결 스냅샷을 별도 삭제했고, 지정된 S3 객체 1개와 비어 있는 작업 전용 버킷을 삭제했다. 다른 객체를 강제 삭제하는 `--force`나 무관한 자원 삭제 명령을 사용하지 않았다.

삭제 후 실제 조회 결과:

- 대상 AMI ID를 서울·자기 계정 필터로 조회: 0개.
- 대상 스냅샷 ID를 서울·자기 계정 필터로 조회: 0개.
- 해당 S3 버킷 HeadBucket: 404 Not Found.
- 원본 EC2 `i-05d34639a30bbfb6a`: `running`, 공인 IP `13.125.99.141`.
- 원본 EBS `vol-0c465503d65f72630`: `in-use`, 위 EC2에 연결됨.
- 원본 `https://kodyssey.kr/` 외부 GET: 200.
- 로컬 암호화 파일의 SHA-256을 다시 확인해 변함없음을 확인했고, 복구키 파일도 존재했다.

증빙: [삭제 전 대상 확인](captures/0231-ami-archive-before-temp-cleanup.png), [삭제 API 성공](captures/0232-ami-archive-temp-cleanup-accepted.png), [삭제 후 부재·원본 유지 확인](captures/0233-ami-archive-temp-deleted-original-preserved.png).

보관 폴더의 manifest와 verification 보고서에도 임시 백업 자원 삭제 결과를 반영했다. 향후 복원할 때 원래 백업 AMI·스냅샷·S3가 남아 있다고 가정하면 안 된다. 로컬 파일을 복호화해 새 비공개 S3에 업로드하고 새 AMI로 복원해야 한다. **이번 임시 백업 자원 정리 완료는 원본 과제 리소스 정리 완료가 아니다.** 과제 원본 EC2·EBS·네트워크와 DNS 정리는 여전히 별도 작업이다.

로컬 작은 시험 파일로 age 암호화→복호화 SHA-256 일치를 확인했다. 이는 도구 시험이지 AWS 재업로드·부팅 복구 시험이 아니다.

## 비용 및 검증 원칙

S3 저장·요청·전송, EBS 스냅샷과 EBS Direct API 사용 비용이 생길 수 있다. 최종 계정 청구·무료 적용 여부는 별도 확인 대상이다. 백업 다운로드만으로 복구 성공을 단정하지 않는다. 원본을 지우기 전에 무결성과 필요한 복원 검증을 고려한다.
