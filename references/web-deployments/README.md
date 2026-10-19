# 외부 웹 배포 참고 저장소

사용자가 지정한 `cloned-web-deployment-repositories` 자료에서 Git 저장소 22개와 일반 참고 자료를 가져왔다. 본인 B3-1 구현물이나 실행 증빙이 아니라 비교·학습용 외부 자료다. 각 저장소의 저작자·라이선스를 따른다.

## 구성

- `<소유자>/<저장소>`: 각각 독립 Git 서브모듈. 원본 폴더명과 저장소명을 유지했다. B3-1/B6-1 등 이름이 섞여 있어도 요청한 원본 모음 전체를 포함한다.
- [`submodules.json`](submodules.json): 등록 경로·원격 URL·고정 커밋·가져오기 당시 원본 미커밋 변경 수.
- [`manifest.json`](manifest.json): 원본 수집 메타데이터를 수정 없이 복사한 자료. 여기의 경로·상태는 원본 수집 시점 기준이며 현재 서브모듈 등록 정보는 `submodules.json`을 따른다.
- [`docs/0001-CIDR.md`](docs/0001-CIDR.md), [`docs/0002-repo-cohort-evaluation.md`](docs/0002-repo-cohort-evaluation.md): 사용자가 포함을 선택한 일반 문서. 외부 평가·관찰 내용을 이 프로젝트의 검증 결과나 평가 PASS로 취급하지 않는다.

원본 디렉터리는 이동·삭제하지 않았다. 각 저장소의 HEAD·작업 트리 상태·origin을 보존하고, 서브모듈은 가져오기 시작 때의 커밋에 고정했다. 원본 작업 트리의 미커밋 변경은 복사하거나 임의로 커밋하지 않았다. 특히 `mackerel07/B6-1`의 변경 14개는 원본에만 남는다.

## 다른 환경에서 받기

이미 상위 저장소를 clone한 상태라면 저장소 루트에서 실행한다.

```sh
git submodule update --init --recursive -- references/web-deployments
```

처음 clone할 때는 `git clone --recurse-submodules`를 사용할 수도 있다. 특정 저장소만 필요하면 다음처럼 경로를 지정한다.

```sh
git submodule update --init -- references/web-deployments/bangahee/B3-1
```

`.gitmodules`에는 로컬 PC 경로 대신 GitHub HTTPS 주소를 등록했다. 서브모듈 내용 전체를 상위 저장소의 일반 파일로 복사해 추적하는 방식이 아니라, 해당 커밋을 가리키는 gitlink를 저장한다. 원격 접근 권한·원격 저장소의 존속 여부에 따라 나중에 내려받지 못할 수 있다.

## 갱신과 주의 사항

- 기본 update는 상위 저장소가 기록한 커밋을 재현한다. 원격 최신 버전으로 자동 갱신했다는 뜻이 아니다.
- 서브모듈에서 실행·배포·패키지 설치를 하지 않았다. 외부 프로젝트의 코드를 검토 없이 실행하거나 AWS에 배포하지 않는다.
- 로컬 원본에서 복제한 뒤 URL을 원격 주소로 맞췄다. 원격 접근·커밋 조회 검증 결과는 `submodules.json`의 해당 필드를 따른다.
- 원격 URL·커밋을 갱신하면 `.gitmodules` 변경과 gitlink 변경을 따로 확인하고 명시적으로 커밋한다. 전역 `protocol.file.allow` 설정을 바꿀 필요는 없다.
- 서브모듈 추가 작업은 `study`에서만 진행한다. main 병합·원격 push는 별도다.


## Windows 파일명 호환성

`mackerel07/B6-1`의 원본 커밋에는 `미션 - AI:SW 기초 (AI:SW Basic).pdf`가 있다. `:` 때문에 Git for Windows의 일반 checkout이 실패한다.

이 작업 폴더에서는 **새 서브모듈에만** sparse-checkout과 해당 파일의 skip-worktree 표시를 적용해 PDF를 물리적으로 만들지 않았다. 다른 파일과 원본 커밋·gitlink는 그대로 유지했다. 원본 디렉터리는 수정하지 않았다. 경로를 인덱스에 읽고 skip 표시할 때만 명령 단위의 `core.protectNTFS=false`를 사용했으며, 보호 설정을 전역·영구 변경하거나 비호환 PDF를 강제로 생성하지 않았다.

이 로컬 sparse 설정은 상위 커밋으로 자동 전달되지 않는다. 따라서 **새 Windows clone에서 전체 submodule update를 실행하면 이 저장소에서 같은 checkout 오류가 날 수 있다.** 다른 저장소는 위의 개별 경로 명령으로 초기화할 수 있고, 이 저장소 전체 파일은 Linux 등 호환 환경에서 checkout하거나 별도 sparse 설정이 필요하다. 제외 파일 목록은 `submodules.json`에도 기록했다.


## 등록 시 검증

- 22개 서브모듈 모두 원본 HEAD와 gitlink를 맞추고, GitHub 원격에서 해당 커밋을 fetch할 수 있음을 확인했다. 확인 시각은 `submodules.json`에 있다.
- 원본 22개 저장소의 HEAD·작업 트리 상태·origin이 바뀌지 않았음을 확인했다.
- 일반 문서 2개와 원본 manifest는 복사 전후 SHA-256을 대조했다. 원문은 편집하지 않았다.
- 원격 fetch 성공은 향후 저장소의 존속·접근 권한이나 모든 운영체제에서의 checkout 성공을 보장하지 않는다.
