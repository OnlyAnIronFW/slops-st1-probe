#!/usr/bin/env bash
# S1 spike 构建脚本：产出一个可复现的 .tar.gz
# 目标 runner: ubuntu-latest（GNU tar / GNU coreutils）
set -euo pipefail

VERSION="${VERSION:-$(git describe --tags --always 2>/dev/null || echo 0.0.0)}"
COMMIT="${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || echo unknown)}"
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-0}"

mkdir -p src dist

cat > src/build-info.txt <<EOF
slops-s1-probe
version=${VERSION}
commit=${COMMIT}
EOF

# 关键：固定 mtime/owner/排序 + gzip -n（不写文件名与时间），同一 commit 两次构建应得到同一 digest
tar --sort=name \
    --mtime="@${SOURCE_DATE_EPOCH}" \
    --owner=0 --group=0 --numeric-owner \
    -cf - src | gzip -n -9 > "dist/slops-s1-probe-${VERSION}.tar.gz"

sha256sum "dist/slops-s1-probe-${VERSION}.tar.gz" > dist/SHA256SUMS
echo "built dist/slops-s1-probe-${VERSION}.tar.gz"
cat dist/SHA256SUMS
