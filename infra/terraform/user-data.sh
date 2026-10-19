#!/bin/bash
set -euo pipefail

# 패키지 미러·네트워크 초기 준비 지연에 한해 제한적으로 재시도합니다.
for attempt in 1 2 3 4 5; do
  if dnf -y install nginx; then
    break
  fi
  if [ "$attempt" -eq 5 ]; then
    echo "Nginx installation failed after 5 attempts" >&2
    exit 1
  fi
  sleep 10
done

# 기본 Welcome 페이지를 사용합니다. B1-1 사이트 배포나 /health 구현은 별도입니다.
systemctl enable --now nginx
curl --fail --silent --show-error --retry 5 --retry-connrefused \
  --retry-delay 2 --max-time 10 http://localhost/ --output /dev/null

echo "B3-1 bootstrap finished: Nginx is serving HTTP locally."
