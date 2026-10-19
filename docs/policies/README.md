# IAM 정책 파일의 관찰 시점과 용도

이 폴더의 파일을 현재 AWS 정책의 완전한 최신 export로 오해하지 않는다. 실제 정책의 저장·버전과 실패/성공 후속 기록은 [정책 설명](../0030-iam-policy-reading-쉬운설명.md), [브라우저 SSH 기록](../0028-browser-ssh-troubleshooting.md), [정리 조회 권한 기록](../0049-cleanup-iam-read-permissions.md)을 따른다.

- `b3-1-ec2-seoul-policy.before-browser-ssh.json`: 브라우저 SSH 보완 전 로컬 정책 사본.
- `b3-1-ec2-seoul-policy.browser-ssh-proposed.json`: 단일 인스턴스·ec2-user·서울 조건의 임시 공개키 전송과 조회 보완 제안본. 파일 존재만으로 적용을 증명하지 않는다.
- `b3-1-ec2-seoul-policy.sg-read-proposed.json`: 보안 그룹 규칙 조회 보완 제안본.
- `b3-1-ec2-seoul-policy.json`: 브라우저 SSH·보안 그룹 조회 보완 후 v3 시점에 맞춘 사본. 이후 정리 단계의 모든 조회 보완까지 포함한 최신본이 아니다.
- `b3-1-ec2-seoul-policy-v4-cleanup-proposed.json`: 정리 초기에 제안한 조회 보완안. 파일명의 v4를 현재 AWS 기본 버전이라는 뜻으로 읽지 않는다.

후속 UI 관찰에서는 기본 버전 v7과 보존 버전 v3~v7을 보았지만, v7 전체 JSON은 다시 export·대조하지 않았다. 여기의 JSON을 바로 적용해 현재 설정을 덮어쓰지 않는다. 또한 리소스 ARN에 연결된 실습 EC2는 이후 종료됐으므로, 새 서버에 사용하려면 대상·조건·필요 권한을 다시 검토해야 한다.

관리 역할의 복구·백업·비용 조회와 최소권한 실습 사용자 `forB3-1`의 작업은 별도다. 과제 사용자에게 AdministratorAccess를 새로 부여하지 않았다는 사실을, 기존 관리 역할도 좁은 권한이었다는 주장으로 바꾸지 않는다.
