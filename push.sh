#!/usr/bin/env bash
# Push to both remotes and wait for the images to actually be live.
#
# The canonical repo (origin, clubtechglobal) is where the team looks; the mirror
# (pages, bradvatne) is what serves the images. Pushing only one leaves the
# signature loading a stale or missing headshot. See README -> Image hosting.
set -euo pipefail

cd "$(dirname "$0")"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is dirty — commit first:" >&2
  git status --short >&2
  exit 1
fi

for remote in origin pages; do
  echo "==> pushing $remote"
  git push "$remote" main
done

# Pages republishes asynchronously; confirm before anyone installs a signature.
echo "==> waiting for GitHub Pages"
base=https://bradvatne.github.io/email-signatures/images
newest=$(git show --name-only --pretty=format: HEAD | grep '^images/' | head -1 || true)
probe=$(basename "${newest:-sig_banner.png}")
head_sha=$(git rev-parse --short HEAD)

for _ in $(seq 1 36); do
  if [[ "$(curl -sIL -o /dev/null -w '%{http_code}' "$base/$probe")" == "200" ]]; then
    echo "live: $base/$probe (at $head_sha)"
    exit 0
  fi
  sleep 5
done

echo "TIMED OUT waiting for $base/$probe — do not install a signature that uses it yet." >&2
echo "Check https://github.com/bradvatne/email-signatures/settings/pages" >&2
exit 1
